# Practice Task 1 — DynamoDB (Phase 2, set 2026-09-08)

Format deliberately mirrors the practical test: a scenario plus requirements,
**no step-by-step instructions**. ~15 minutes.

## Scenario
The café wants to move its online order tracking off the relational database.
Orders arrive in bursts — quiet all morning, then a spike over lunch — and the
team cannot predict the load, so they do not want to manage capacity settings.

Each order record holds: the customer's email address, the time the order was
placed, an order ID, a list of items, the total amount, and a status
(`PENDING`, `READY`, `COLLECTED`).

The application must be able to:
- **(a)** retrieve **all orders for one customer, newest first**, in a single query
- **(b)** retrieve **one specific order** for a customer directly, without scanning
- **(c)** let the kitchen display list **every order currently in `READY` status**,
  across all customers, without scanning the whole table
- **(d)** survive an accidental bad write — restore the table to any second in
  the last few days

## Requirements
1. Create a table named `CafeOrders`.
2. Choose a **partition key and sort key** satisfying (a) and (b).
3. Use the capacity mode appropriate to the described traffic.
4. Add whatever is needed for (c).
5. Enable whatever satisfies (d).
6. Add **one** order item with all six attributes populated.

## What the user must report back
- Table name, partition key (+type), sort key (+type)
- Capacity mode
- Name/keys of whatever was added for (c), and **which projection type**
- What was enabled for (d)
- The item's attributes
- One sentence each: why that partition key, and why that choice for (c)

## Skills under test
| Requirement | What it is really checking |
|---|---|
| (a)+(b) | Composite primary key: partition key = the thing you always know
  (customer email), sort key = the thing that gives ordering *and* uniqueness. Sort
  key ordering is what gives "newest first" (ScanIndexForward=false). |
| 3 | **On-demand** — unpredictable, bursty, no capacity management wanted. Provisioned
  would be the wrong answer here. |
| (c) | **GSI** (different partition key = status), not an LSI. LSI must share the
  table's partition key and can only be created at table-creation time. Projection
  type is the follow-up: KEYS_ONLY / INCLUDE / ALL, and why. |
| (d) | **Point-in-time recovery (PITR)** — per-second restore for the last 35 days.
  On-demand backup is a snapshot, not any-second, so it does not satisfy (d). |

**Status:** issued 2026-09-08, awaiting the user's answer. Mark it when it comes in.
