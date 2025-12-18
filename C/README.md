# Part C — Office Bakery Multithreaded Simulation

## Problem Overview

This program simulates an office bakery with the following constraints:

- **Resources:** 4 ovens, 4 chefs (each a thread), 1 cash register, 4 sofa seats, standing room for additional customers, and a maximum shop capacity of 25 customers.
- **Customer Flow:** Customers arrive at specified times, enter if space is available, sit on the sofa if possible (otherwise stand), request cake when a chef is available, pay after receiving cake, and leave after payment.
- **Chef Flow:** Chefs prioritize accepting payments over baking cakes. They bake cakes for customers on the sofa and accept payments one at a time (due to a single register).

## Input Format

```
<time_stamp> Customer <id>
...
<EOF>
```

Example:
```
10 Customer 1
11 Customer 2
12 Customer 3
<EOF>
```

## Output Format

Each action is printed with a timestamp, actor, id, and action. Example:

```
10 Customer 1 enters
11 Customer 2 enters
11 Customer 1 sits
...
```

## Implementation Details

- **Threads:** Each chef and customer is a separate thread.
- **Synchronization:** Mutexes and condition variables are used to manage access to shared resources (sofa, register, payment queue).
- **Queues:** Customers waiting for cake and payment are managed via linked lists.
- **Actions:**
  - Customer: enters, sits/stands, requests cake, pays, leaves.
  - Chef: bakes cake, accepts payment.

## Assumptions

1. **Timing:**
   - Every customer action (enter, sit, stand, request cake, pay, leave) takes **1 second**.
   - Chef actions (bake cake, accept payment) take **2 seconds**.
2. **Entry:**
   - Customers do not enter if the shop is at capacity (25), they just leave.
   - If the sofa is full, customers stand and print a "stands" message.
3. **Sofa/Standing:**
   - Standing to sitting (when a sofa seat becomes available) takes 1 second and is printed.
   - Once seated, the seat is reserved until the customer leaves.
4. **Cake Request:**
   - Customers only request cake when a chef is available and after sitting for 1 second.
   - Up to 4 customers can request cake concurrently (sofa capacity).
   - Up to 4 chefs can bake concurrently.
5. **Payment:**
   - Customers pay after receiving cake.
   - Only one chef can accept payment at a time (single register).
   - Chefs prioritize accepting payment over baking.
   - Customer must pay before chef accepts payment; chef must accept payment before customer leaves.
6. **Order:**
   - The customer who has been on the sofa the longest is served first.
   - Standing customers move to the sofa in order of arrival when seats free up.
7. **Atomicity:**
   - Actions are not split; once started, they run to completion (e.g., chef spends 2 seconds uninterrupted for payment).
8. **Thread Safety:**
   - All shared state is protected by mutexes.
   - All print statements are thread-safe.
9. **Other:**
   - Chefs do not print "learning new recipes" actions.
   - Customer and chef IDs are printed as per input and requirements.
   - The simulation ends when all customers have left.
   - when all 4 chefs are busy doing some other work and at that time if a customer is seated, he/she does not request for a cake unless a chef is free

## How to Run

Compile:
```bash
gcc -O2 bakery_fixed.c -o bakery_fixed -pthread
```

Run:
```bash
./bakery_fixed < input.txt
```
Where `input.txt` contains the customer arrival times and IDs as specified above.
