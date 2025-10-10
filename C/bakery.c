// bakery.c
// Compile: gcc -O2 bakery.c -o bakery -pthread

#define _XOPEN_SOURCE 700
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <time.h>
#include <stdarg.h>


#define MAX_CUSTOMERS_INPUT 1000
#define MAX_IN_SHOP 25
#define SOFA_CAP 4
#define NUM_CHEFS 4

typedef struct Customer {
    int id;
    int arrival_time; // seconds from start
    int is_on_sofa;   // 1 if sitting, 0 if standing
    int being_served; // 1 if chef picked them for baking
    int in_payment;   // 1 if in payment process, 0 otherwise
    // synchronization objects for this customer
    pthread_cond_t cv_start_bake;
    pthread_cond_t cv_bake_done;
    pthread_cond_t cv_payment_start;
    pthread_cond_t cv_payment_done;
    pthread_mutex_t mtx;
    struct Customer *next;         // For waiting list
    struct Customer *payment_next; // For payment queue
} Customer;

// Global state
pthread_mutex_t state_mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t print_mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t chef_wakeup_cv = PTHREAD_COND_INITIALIZER;

Customer *waiting_head = NULL, *waiting_tail = NULL; // Queue of all waiting customers
int sofa_count = 0;    // Count of customers sitting on sofa
int standing_count = 0; // Count of customers standing

Customer *payment_head = NULL, *payment_tail = NULL; // FIFO payment queue
int in_shop_count = 0;

time_t sim_start;

int stop_all = 0;


int now_sec() 
{
    time_t t = time(NULL);
    return (int)(t - sim_start);
}

void ts_printf(const char *fmt, ...) 
{
    pthread_mutex_lock(&print_mtx);
    int t = now_sec();
    va_list ap;
    va_start(ap, fmt);
    printf("%d ", t);
    vprintf(fmt, ap);
    printf("\n");
    fflush(stdout);
    va_end(ap);
    pthread_mutex_unlock(&print_mtx);
}

// Helper functions
void enqueue_waiting(Customer *c) {
    c->next = NULL;
    if (!waiting_tail) { 
        waiting_head = waiting_tail = c; 
       // ts_printf("DEBUG: Customer %d added to empty waiting list", c->id);
    } else { 
        waiting_tail->next = c; 
        waiting_tail = c; 
        //ts_printf("DEBUG: Customer %d added to waiting list after Customer %d", c->id, waiting_tail->id);
    }
}

Customer* find_next_unserved_sofa_customer() {
    // Find first customer on sofa who hasn't been picked for service yet and isn't in payment
    Customer *c = waiting_head;
    while (c) {
        if (c->is_on_sofa && !c->being_served && !c->in_payment) {
            return c;
        }
        c = c->next;
    }
    return NULL;
}

void remove_from_waiting(Customer *target) {
    if (!target) return;
    
    //ts_printf("DEBUG: Attempting to remove Customer %d from waiting list", target->id);
    
    Customer *prev = NULL;
    Customer *c = waiting_head;
    
    while (c) {
        if (c == target) {
           // ts_printf("DEBUG: Found Customer %d in waiting list, removing...", target->id);
            if (prev) {
                prev->next = c->next;
            } else {
                waiting_head = c->next;
            }
            if (c == waiting_tail) {
                waiting_tail = prev;
            }
            c->next = NULL;
            
            // Update counts - only for standing customers
            // Sofa count will be handled by caller
            if (!c->is_on_sofa) {
                standing_count--;
               // ts_printf("DEBUG: Decremented standing_count to %d", standing_count);
            }
            return;
        }
        prev = c;
        c = c->next;
    }
   // ts_printf("DEBUG: Customer %d NOT found in waiting list!", target->id);
}



void move_standing_to_sofa() {
    // Find first standing customer and move them to sofa
    //ts_printf("DEBUG: move_standing_to_sofa called, scanning waiting list...");
   // ts_printf("DEBUG: sofa_count=%d, standing_count=%d", sofa_count, standing_count);
    
    Customer *c = waiting_head;
    int count = 0;
    while (c) {
        //ts_printf("DEBUG: Customer %d: is_on_sofa=%d, being_served=%d", c->id, c->is_on_sofa, c->being_served);
        if (!c->is_on_sofa && !c->being_served) {
            c->is_on_sofa = 1;
            sofa_count++;
            standing_count--;
            ts_printf("Customer %d sits", c->id);
            
            // Signal the customer that they can now sit
            pthread_mutex_lock(&c->mtx);
            pthread_cond_signal(&c->cv_start_bake);
            pthread_mutex_unlock(&c->mtx);
            
            return;
        }
        c = c->next;
        count++;
        if (count > 30) {
           // ts_printf("DEBUG: Breaking loop at count %d", count);
            break; // Prevent infinite loop
        }
    }
    // If we reach here, no standing customer was found
    //ts_printf("DEBUG: Scanned %d customers, no standing customers found", count);
}

void enqueue_payment(Customer *c) {
    c->payment_next = NULL;
    if (!payment_tail) { payment_head = payment_tail = c; } 
    else { payment_tail->payment_next = c; payment_tail = c; }
}

Customer* dequeue_payment() {
    if (!payment_head) return NULL;
    Customer *c = payment_head;
    payment_head = payment_head->payment_next;
    if (!payment_head) payment_tail = NULL;
    c->payment_next = NULL;
    return c;
}





pthread_mutex_t register_mtx = PTHREAD_MUTEX_INITIALIZER;

void* chef_thread_fn(void *arg) 
{
    int chef_id = *((int*)arg);
    free(arg);

    while (1) 
    {
        pthread_mutex_lock(&state_mtx);

        // Priority 1: Process payments
        if (payment_head) 
        {
            Customer *cust = dequeue_payment();
            pthread_mutex_unlock(&state_mtx);

            pthread_mutex_lock(&register_mtx);
            ts_printf("Chef %d accepts payments for Customer %d", chef_id, cust->id);
            sleep(2);

            pthread_mutex_lock(&cust->mtx);
            pthread_cond_signal(&cust->cv_payment_done);
            pthread_mutex_unlock(&cust->mtx);

            pthread_mutex_unlock(&register_mtx);

            continue;
        }

        // Priority 2: Serve customers on sofa
        Customer *cust = find_next_unserved_sofa_customer();
        if (cust) {
            cust->being_served = 1;
            pthread_mutex_unlock(&state_mtx);

            pthread_mutex_lock(&cust->mtx);
            pthread_cond_signal(&cust->cv_start_bake);
            pthread_mutex_unlock(&cust->mtx);

            ts_printf("Chef %d bakes for Customer %d", chef_id, cust->id);
            sleep(2);

            pthread_mutex_lock(&cust->mtx);
            pthread_cond_signal(&cust->cv_bake_done);
            pthread_mutex_unlock(&cust->mtx);

            continue;
        }

        // Nothing to do, wait
        pthread_cond_wait(&chef_wakeup_cv, &state_mtx);

        if (stop_all) {
            pthread_mutex_unlock(&state_mtx);
            break;
        }
        pthread_mutex_unlock(&state_mtx);
    }

    return NULL;
}

void* customer_thread_fn(void *arg) 
{
    Customer *c = (Customer*)arg;
    
    while (1) 
    {
        int t = now_sec();
        if (t >= c->arrival_time) break;
        sleep(1);
    }

    pthread_mutex_lock(&state_mtx);
    if (in_shop_count >= MAX_IN_SHOP) 
    {
        pthread_mutex_unlock(&state_mtx);
        ts_printf("Customer %d cannot enter - shop at capacity (%d/%d)", c->id, in_shop_count, MAX_IN_SHOP);
        return NULL;
    }
    in_shop_count++;
    pthread_mutex_unlock(&state_mtx);

    ts_printf("Customer %d enters", c->id);

    pthread_mutex_lock(&state_mtx);
    c->is_on_sofa = 0;
    c->being_served = 0;
    c->in_payment = 0;

    enqueue_waiting(c);
    
    // New customer should only sit if sofa has space AND no one is standing
    if (sofa_count < SOFA_CAP && standing_count == 0) 
    {
        c->is_on_sofa = 1;
        sofa_count++;
        ts_printf("Customer %d sits", c->id);
        pthread_mutex_unlock(&state_mtx);
        
        // Sitting takes 1 second
        sleep(1);
        
        // Now signal chefs that customer is ready
        pthread_mutex_lock(&state_mtx);
        pthread_cond_signal(&chef_wakeup_cv);
        pthread_mutex_unlock(&state_mtx);
    } 
    else 
    {
        standing_count++;
        ts_printf("Customer %d stands", c->id);
        pthread_cond_signal(&chef_wakeup_cv);
        pthread_mutex_unlock(&state_mtx);
    }

    // Wait for chef to start baking (only sofa customers will be signaled initially)
    pthread_mutex_lock(&c->mtx);
    pthread_cond_wait(&c->cv_start_bake, &c->mtx);
    pthread_mutex_unlock(&c->mtx);

    ts_printf("Customer %d requests cake", c->id);
    sleep(1);

    pthread_mutex_lock(&c->mtx);
    pthread_cond_wait(&c->cv_bake_done, &c->mtx);
    pthread_mutex_unlock(&c->mtx);

    pthread_mutex_lock(&state_mtx);
    c->being_served = 0;  // Reset being_served flag after baking is done
    c->in_payment = 1;    // Mark as in payment process
    enqueue_payment(c);
    pthread_cond_broadcast(&chef_wakeup_cv);
    pthread_mutex_unlock(&state_mtx);

    ts_printf("Customer %d pays", c->id);
    sleep(1);

    // Wait for chef to finish accepting payment
    pthread_mutex_lock(&c->mtx);
    pthread_cond_wait(&c->cv_payment_done, &c->mtx);
    pthread_mutex_unlock(&c->mtx);

    pthread_mutex_lock(&state_mtx);
    
    // Before removing from waiting, check if this customer was on sofa
    int was_on_sofa = c->is_on_sofa;
    
    remove_from_waiting(c);

    // If a sofa customer left, try to move a standing customer to sofa
    if (was_on_sofa) {
       // ts_printf("DEBUG: Customer %d was on sofa, standing_count=%d", c->id, standing_count);
        if (standing_count > 0) {
            move_standing_to_sofa();
            pthread_cond_signal(&chef_wakeup_cv);
        } else {
            // No standing customers, just decrement sofa count
            sofa_count--;
            //ts_printf("DEBUG: No standing customers, sofa_count now %d", sofa_count);
        }
    }
    
    in_shop_count--;
    pthread_mutex_unlock(&state_mtx);

    ts_printf("Customer %d leaves", c->id);

    // NOW free the sofa seat and move standing customer if any
   
    

    return NULL;
}

int main() 
{
    char line[256];
    Customer *custs[MAX_CUSTOMERS_INPUT];
    int cust_count = 0;

    while (fgets(line, sizeof(line), stdin)) 
    {
        char *s = line;
        while (*s == ' ' || *s == '\t') s++;
        if (strlen(s) == 0) continue;
        if (strncmp(s, "<EOF>", 5) == 0) break;

        int t, id;
        char tmp[50];
        if (sscanf(s, "%d %s %d", &t, tmp, &id) == 3) 
        {
            Customer *c = malloc(sizeof(Customer));
            memset(c,0,sizeof(Customer));
            c->id = id;
            c->arrival_time = t;
            pthread_cond_init(&c->cv_start_bake, NULL);
            pthread_cond_init(&c->cv_bake_done, NULL);
            pthread_cond_init(&c->cv_payment_start, NULL);
            pthread_cond_init(&c->cv_payment_done, NULL);
            pthread_mutex_init(&c->mtx, NULL);
            c->next = NULL;
            c->payment_next = NULL;
            custs[cust_count++] = c;
        }
    }

    sim_start = time(NULL);

    pthread_t chefs[NUM_CHEFS];
    for (int i=0;i<NUM_CHEFS;i++) 
    {
        int *arg = malloc(sizeof(int));
        *arg = i+1;
        pthread_create(&chefs[i], NULL, chef_thread_fn, arg);
    }

    pthread_t cust_threads[cust_count];
    for (int i=0;i<cust_count;i++) 
    {
        pthread_create(&cust_threads[i], NULL, customer_thread_fn, (void*)custs[i]);
    }

    for (int i=0;i<cust_count;i++) 
    {
        pthread_join(cust_threads[i], NULL);
    }

    pthread_mutex_lock(&state_mtx);
    stop_all = 1;
    pthread_cond_broadcast(&chef_wakeup_cv);
    pthread_mutex_unlock(&state_mtx);

    for (int i=0;i<NUM_CHEFS;i++) {
        pthread_join(chefs[i], NULL);
    }

    for (int i=0;i<cust_count;i++) {
        pthread_cond_destroy(&custs[i]->cv_start_bake);
        pthread_cond_destroy(&custs[i]->cv_bake_done);
        pthread_cond_destroy(&custs[i]->cv_payment_start);
        pthread_cond_destroy(&custs[i]->cv_payment_done);
        pthread_mutex_destroy(&custs[i]->mtx);
        free(custs[i]);
    }

    return 0;
}