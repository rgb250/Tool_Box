# Table of Contents

## 1 Aggregation
### a. aggregate()
```json
db.collection.aggregate(
    [
    {$match: {col_x: 'val_x', col_y: 'val_y'}},                 // filtering
    {$group: {_id: {"$col_grp"}, total: {$sum: "$col_to_sum"}}},  // aggregation
    {$sort: {total: -1}},                                       // sorting
    {$limit: 5}],                                               // number max of rows
    {
        cursor: {batchSize: 0}                                  // empty first batch
    }
)
```