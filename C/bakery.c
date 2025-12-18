// bakery_fixed.c - WITH ALL FIXES
// Compile: gcc -O2 bakery_fixed.c -o bakery_fixed -pthread

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
    int arrival_time;
    int is_on_sofa;
    int ready_to_request;
    int being_served;
    int payment_ready;
    pthread_cond_t cv_sit;
    pthread_cond_t cv_start_bake;
    pthread_cond_t cv_bake_done;
    pthread_cond_t cv_payment_done;
    pthread_mutex_t mtx;
    struct Customer *next;
    struct Customer *payment_next;
} Customer;

// Global state
pthread_mutex_t state_mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t print_mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t register_mtx = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t chef_wakeup_cv = PTHREAD_COND_INITIALIZER;

Customer *waiting_head = NULL, *waiting_tail = NULL;
Customer *payment_head = NULL, *payment_tail = NULL;

int sofa_count = 0;
int standing_count = 0;
int in_shop_count = 0;
int stop_all = 0;

time_t sim_start;

// Thread-safe timestamp printing
void ts_printf(const char *fmt, ...) {
    pthread_mutex_lock(&print_mtx);
    
    time_t now;
    time(&now);
    int elapsed = now - sim_start;
    
    printf("%d ", elapsed);
    
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args);
    va_end(args);
    
    printf("\n");
    fflush(stdout);
    
    pthread_mutex_unlock(&print_mtx);
}

void enqueue_waiting(Customer *c) {
    c->next = NULL;
    if (!waiting_tail) {
        waiting_head = waiting_tail = c;
    } else {
        waiting_tail->next = c;
        waiting_tail = c;
    }
}

void enqueue_payment(Customer *c) {
    c->payment_next = NULL;
    if (!payment_tail) {
        payment_head = payment_tail = c;
    } else {
        payment_tail->payment_next = c;
        payment_tail = c;
    }
}

Customer* dequeue_payment() {
    if (!payment_head) return NULL;
    Customer *c = payment_head;
    payment_head = c->payment_next;
    if (!payment_head) payment_tail = NULL;
    c->payment_next = NULL;
    return c;
}

Customer* find_next_sofa_customer() {
    Customer *c = waiting_head;
    while (c) {
        if (c->is_on_sofa && c->ready_to_request && !c->being_served) {
            return c;
        }
        c = c->next;
    }
    return NULL;
}

// --- FIX ---
// This new function finds the next standing customer, updates the global counts,
// and returns a pointer to that customer. It does NOT signal them, to avoid
// holding the main lock for too long.
Customer* find_and_prepare_standing_customer() {
    Customer *c = waiting_head;
    while (c) {
        // Find the first customer who is standing and not already being served
        if (!c->is_on_sofa && !c->being_served) {
            // Update the state for this customer
            c->is_on_sofa = 1;
            sofa_count++;
            standing_count--;
            // Return the customer to be signaled later, outside the lock
            return c;
        }
        c = c->next;
    }
    return NULL; // No standing customer found
}

// void* chef_thread_fn(void *arg) {
//     int chef_id = *(int*)arg;
    
//     while (!stop_all) {
//         pthread_mutex_lock(&state_mtx);
        
//         // Priority 1: Handle payments
//         Customer *payment_cust = dequeue_payment();
//         if (payment_cust) {
//             pthread_mutex_lock(&register_mtx);
//             pthread_mutex_unlock(&state_mtx);
            
//             ts_printf("Chef %d accepts payment for Customer %d", chef_id, payment_cust->id);
//             sleep(2); // Payment takes 2 seconds
            
//             pthread_mutex_lock(&payment_cust->mtx);
//             pthread_cond_signal(&payment_cust->cv_payment_done);
//             pthread_mutex_unlock(&payment_cust->mtx);
            
//             pthread_mutex_unlock(&register_mtx);
//             continue;
//         }
        
//         // Priority 2: Serve customers on sofa who are ready
//         Customer *cust = find_next_sofa_customer();
//         if (cust) {
//             cust->being_served = 1;
//             pthread_mutex_unlock(&state_mtx);
            
//             pthread_mutex_lock(&cust->mtx);
//             pthread_cond_signal(&cust->cv_start_bake);
//             pthread_cond_wait(&cust->cv_start_bake, &cust->mtx);
//             pthread_mutex_unlock(&cust->mtx);
            
//             ts_printf("Chef %d bakes for Customer %d", chef_id, cust->id);
//             sleep(2); // Baking takes 2 seconds
            
//             pthread_mutex_lock(&cust->mtx);
//             pthread_cond_signal(&cust->cv_bake_done);
//             pthread_mutex_unlock(&cust->mtx);
            
//             continue;
//         }
        
//         // Nothing to do, wait
//         pthread_cond_wait(&chef_wakeup_cv, &state_mtx);
//         pthread_mutex_unlock(&state_mtx);
//     }
    
//     return NULL;
// }

void* chef_thread_fn(void *arg) {
    int chef_id = *(int*)arg;
    
    while (!stop_all) {
        pthread_mutex_lock(&state_mtx);
        
        // --- FIX STARTS HERE: REVISED PAYMENT LOGIC ---

        // Priority 1: Handle payments, BUT ONLY if the register is free.
        // First, PEEK at the payment queue without taking anyone.
        if (payment_head != NULL) {
            // Now, TRY to get the register lock without blocking.
            if (pthread_mutex_trylock(&register_mtx) == 0) {
                // Success! The register is free AND there's a customer.
                // Now we can safely dequeue the customer and process the payment.
                Customer *payment_cust = dequeue_payment();
                
                // We have our task, so we can release the main state lock.
                pthread_mutex_unlock(&state_mtx);
                
                ts_printf("Chef %d accepts payment for Customer %d", chef_id, payment_cust->id);
                sleep(2); // Payment takes 2 seconds
                
                pthread_mutex_lock(&payment_cust->mtx);
                pthread_cond_signal(&payment_cust->cv_payment_done);
                pthread_mutex_unlock(&payment_cust->mtx);
                
                // IMPORTANT: Release the register lock for the next chef.
                pthread_mutex_unlock(&register_mtx);
                continue; // Restart the main loop.
            }
            // If trylock failed, it means another chef is using the register.
            // This chef should NOT wait. It should fall through to check for baking.
        }
        
        // --- END FIX ---
        
        // Priority 2: Serve customers on sofa who are ready
        Customer *cust = find_next_sofa_customer();
        if (cust) {
            cust->being_served = 1;
            pthread_mutex_unlock(&state_mtx);
            
            // Wait for customer to request cake first
            pthread_mutex_lock(&cust->mtx);
            pthread_cond_signal(&cust->cv_start_bake);
            pthread_cond_wait(&cust->cv_start_bake, &cust->mtx);
            pthread_mutex_unlock(&cust->mtx);
            
            ts_printf("Chef %d bakes for Customer %d", chef_id, cust->id);
            sleep(2); // Baking takes 2 seconds
            
            pthread_mutex_lock(&cust->mtx);
            pthread_cond_signal(&cust->cv_bake_done);
            pthread_mutex_unlock(&cust->mtx);
            
            continue;
        }
        
        // Nothing to do, wait
        pthread_cond_wait(&chef_wakeup_cv, &state_mtx);
        pthread_mutex_unlock(&state_mtx);
    }
    
    return NULL;
}

void* customer_thread_fn(void *arg) {
    Customer *c = (Customer*)arg;
    
    while (1) {
        time_t now;
        time(&now);
        if ((now - sim_start) >= c->arrival_time) break;
        sleep(1);
    }
    
    pthread_mutex_lock(&state_mtx);
    if (in_shop_count >= MAX_IN_SHOP) {
        pthread_mutex_unlock(&state_mtx);
        ts_printf("Customer %d cannot enter (shop full)", c->id);
        return NULL;
    }
    
    in_shop_count++;
    enqueue_waiting(c);
    pthread_mutex_unlock(&state_mtx);
    
    ts_printf("Customer %d enters", c->id);
    sleep(1);
    
    pthread_mutex_lock(&state_mtx);
    if (sofa_count < SOFA_CAP) {
        c->is_on_sofa = 1;
        sofa_count++;
        pthread_mutex_unlock(&state_mtx);
        
        ts_printf("Customer %d sits", c->id);
        sleep(1);
    } else {
        standing_count++;
        pthread_mutex_unlock(&state_mtx);
        
        ts_printf("Customer %d stands", c->id);
        sleep(1);
        
        pthread_mutex_lock(&c->mtx);
        while (!c->is_on_sofa) {
            pthread_cond_wait(&c->cv_sit, &c->mtx);
        }
        pthread_mutex_unlock(&c->mtx);
        
        // --- FIX ---
        // Sleep first to simulate the action, then print at the correct timestamp.
        sleep(1);
        ts_printf("Customer %d sits", c->id);
    }
    
    ts_printf("Customer %d requests cake", c->id);
    sleep(1);
    
    pthread_mutex_lock(&state_mtx);
    c->ready_to_request = 1;
    pthread_cond_broadcast(&chef_wakeup_cv);
    pthread_mutex_unlock(&state_mtx);
    
    pthread_mutex_lock(&c->mtx);
    while (!c->being_served) {
        pthread_cond_wait(&c->cv_start_bake, &c->mtx);
    }
    
    pthread_cond_signal(&c->cv_start_bake);
    pthread_mutex_unlock(&c->mtx);
    
    pthread_mutex_lock(&c->mtx);
    pthread_cond_wait(&c->cv_bake_done, &c->mtx);
    pthread_mutex_unlock(&c->mtx);
    
    ts_printf("Customer %d pays", c->id);
    sleep(1);
    
    pthread_mutex_lock(&state_mtx);
    enqueue_payment(c);
    pthread_cond_broadcast(&chef_wakeup_cv);
    pthread_mutex_unlock(&state_mtx);
    
    pthread_mutex_lock(&c->mtx);
    pthread_cond_wait(&c->cv_payment_done, &c->mtx);
    pthread_mutex_unlock(&c->mtx);
    
    ts_printf("Customer %d leaves", c->id);
    
    // --- FIX ---
    // The critical section is now much shorter to prevent blocking chefs.
    Customer *customer_to_signal = NULL;

    // 1. Lock state for quick updates
    pthread_mutex_lock(&state_mtx);
    in_shop_count--;
    sofa_count--;
    
    // 2. Find who to signal next, but don't signal yet.
    if (standing_count > 0) {
        customer_to_signal = find_and_prepare_standing_customer();
    }
    
    pthread_cond_broadcast(&chef_wakeup_cv);

    // 3. UNLOCK IMMEDIATELY! The critical work is done.
    pthread_mutex_unlock(&state_mtx);
    
    // 4. Now that the main lock is free, signal the next customer.
    if (customer_to_signal) {
        pthread_mutex_lock(&customer_to_signal->mtx);
        pthread_cond_signal(&customer_to_signal->cv_sit);
        pthread_mutex_unlock(&customer_to_signal->mtx);
    }
    // --- END FIX ---
    
    return NULL;
}

int main() {
    time(&sim_start);
    
    char line[256];
    Customer *custs[MAX_CUSTOMERS_INPUT];
    int cust_count = 0;
    
    while (fgets(line, sizeof(line), stdin)) {
        char *s = line;
        while (*s == ' ' || *s == '\t') s++;
        if (strlen(s) == 0) continue;
        if (strncmp(s, "<EOF>", 5) == 0) break;
        
        int t, id;
        char tmp[50];
        if (sscanf(s, "%d %s %d", &t, tmp, &id) == 3) {
            Customer *c = malloc(sizeof(Customer));
            c->id = id;
            c->arrival_time = t;
            c->is_on_sofa = 0;
            c->ready_to_request = 0;
            c->being_served = 0;
            c->payment_ready = 0;
            c->next = NULL;
            c->payment_next = NULL;
            
            pthread_cond_init(&c->cv_sit, NULL);
            pthread_cond_init(&c->cv_start_bake, NULL);
            pthread_cond_init(&c->cv_bake_done, NULL);
            pthread_cond_init(&c->cv_payment_done, NULL);
            pthread_mutex_init(&c->mtx, NULL);
            
            custs[cust_count++] = c;
        }
    }
    
    pthread_t chef_threads[NUM_CHEFS];
    int chef_ids[NUM_CHEFS];
    for (int i = 0; i < NUM_CHEFS; i++) {
        chef_ids[i] = i + 1;
        pthread_create(&chef_threads[i], NULL, chef_thread_fn, &chef_ids[i]);
    }
    
    pthread_t cust_threads[MAX_CUSTOMERS_INPUT];
    for (int i = 0; i < cust_count; i++) {
        pthread_create(&cust_threads[i], NULL, customer_thread_fn, custs[i]);
    }
    
    for (int i = 0; i < cust_count; i++) {
        pthread_join(cust_threads[i], NULL);
    }
    
    pthread_mutex_lock(&state_mtx);
    stop_all = 1;
    pthread_cond_broadcast(&chef_wakeup_cv);
    pthread_mutex_unlock(&state_mtx);
    
    for (int i = 0; i < NUM_CHEFS; i++) {
        pthread_join(chef_threads[i], NULL);
    }
    
    for (int i = 0; i < cust_count; i++) {
        free(custs[i]);
    }
    
    return 0;
}