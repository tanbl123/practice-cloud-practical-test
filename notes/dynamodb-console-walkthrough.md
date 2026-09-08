# DynamoDB — console walkthrough (first time, 2026-09-08)

User had never touched DynamoDB. Walkthrough uses a throwaway `DemoProducts`
table deliberately structured **differently** from the café practice task, so the
practice task still tests them.

## The three ideas
- **Table → items → attributes.** Item = row, attribute = field.
- **No schema except the key.** Items in one table may have different attributes.
  You never "add a column".
- **The key decides what you can look up fast.**
  - Partition key alone → uniquely identifies one item.
  - **Partition key + sort key** (composite) → many items share the partition key,
    ordered and distinguished by the sort key. This is what gives "everything for
    customer X, newest first" in one query. Uniqueness = the **combination**.
- **Query** uses the key, reads only what it needs. **Scan** reads the whole
  table. *"Without scanning"* in a requirement = the key or an index must support it.

## Console path
**DynamoDB → Tables → Create table**
- Table name, **Partition key** (+String/Number/Binary), optional **Sort key**.
- **Table settings → Customize settings** reveals:
  - **Table class**: Standard vs Standard-IA (cheap storage, pricier reads).
  - **Capacity**: **On-demand** (pay per request, bursty/unpredictable, no
    management) vs **Provisioned** (RCU/WCU, steady predictable load, has auto
    scaling). *The scenario wording tells you which — near-certain exam question.*
  - **Secondary indexes** — an **LSI can ONLY be created here**, at table creation.
  - **Encryption at rest** — AWS owned / AWS managed / customer managed KMS key.

**Add items:** select table → **Explore table items** → **Create item** →
Form view or JSON view.

**Query vs Scan:** in Explore table items, the Scan/Query toggle. Query asks for
a partition key value. **You cannot query on a non-key attribute** — there is no
box for it. That constraint is why secondary indexes exist; it is the single most
important idea in DynamoDB.

**Create a GSI:** table → **Indexes** tab → **Create index** → its own partition
key (+ optional sort key) → **Attribute projections**:
- **All** — every attribute copied in. Most flexible, most storage.
- **Keys only** — smallest, cheapest.
- **Include** — keys plus a named list. Middle ground.

**PITR:** table → **Backups** tab → Point-in-time recovery → Edit → On.
Restores to **any second in the last 35 days**. Contrast **on-demand backup** =
manual snapshot of one moment. *"Any point in time" / "last N days" → PITR.*

**Also exists:** Additional settings → **TTL** (attribute holding an expiry
timestamp; DynamoDB deletes expired items free — answer for "session data should
expire"). Exports and streams → **DynamoDB Streams** (change log that can trigger
Lambda — answer for "when an item changes, do something").

## GSI vs LSI — memorise
| | GSI | LSI |
|---|---|---|
| Partition key | **Any attribute** | **Must be the table's partition key** |
| When creatable | **Any time** | **Only at table creation** |
| Capacity | Its own | Shares the table's |

"Query by a completely different attribute" → **GSI**. If a scenario needs an LSI
on an existing table, the answer is "you can't — recreate the table".

## Teardown
**Tables → `DemoProducts` → Delete** (type `confirm`). GSI and PITR go with it.
Cost ≈ a fraction of a cent (on-demand bills per request).
