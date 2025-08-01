## What is a CTE?

**CTE** stands for **Common Table Expression** — a temporary result set you can reference within a `SELECT`, `INSERT`, `UPDATE`, or `DELETE` statement.

**Syntax:**

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT * FROM cte_name;
```

---

## What is a **Recursive CTE**?

A **recursive CTE** is a CTE that **refers to itself** to solve hierarchical or repetitive problems — like organization trees, file systems, or number generation.

It has **two parts**:

1. **Anchor member** – the base case (runs once)
2. **Recursive member** – builds on the anchor by repeatedly calling itself until a condition is met

---

## Syntax of Recursive CTE

```sql
WITH RECURSIVE cte_name AS (
    -- Anchor member: the base case
    SELECT ...

    UNION ALL

    -- Recursive member: references cte_name
    SELECT ...
    FROM cte_name
    JOIN ...
    WHERE ...
)
SELECT * FROM cte_name;
```

---

## Example 1: Generate Numbers from 1 to 5

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS num            -- Anchor

    UNION ALL

    SELECT num + 1             -- Recursive
    FROM numbers
    WHERE num < 5
)
SELECT * FROM numbers;
```

### Output:

| num |
| --- |
| 1   |
| 2   |
| 3   |
| 4   |
| 5   |

---

## Example 2: Employee Hierarchy

### Table: `employees`

| id | name  | manager\_id |
| -- | ----- | ----------- |
| 1  | Alice | NULL        |
| 2  | Bob   | 1           |
| 3  | Carol | 2           |
| 4  | David | 2           |
| 5  | Eve   | 1           |

### Goal: Find all employees under Alice (id = 1), including levels

```sql
WITH RECURSIVE org_chart AS (
    -- Anchor: start with Alice
    SELECT id, name, manager_id, 0 AS level
    FROM employees
    WHERE id = 1

    UNION ALL

    -- Recursive: find direct reports
    SELECT e.id, e.name, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart;
```

### Output:

| id | name  | manager\_id | level |
| -- | ----- | ----------- | ----- |
| 1  | Alice | NULL        | 0     |
| 2  | Bob   | 1           | 1     |
| 5  | Eve   | 1           | 1     |
| 3  | Carol | 2           | 2     |
| 4  | David | 2           | 2     |

---

## Summary

| Part           | Role                                    |
| -------------- | --------------------------------------- |
| Anchor         | Base case (starts recursion)            |
| Recursive part | Expands from previous result            |
| `UNION ALL`    | Combines both parts                     |
| `level` column | Helps track depth in the hierarchy      |
| Stop condition | `WHERE` clause to prevent infinite loop |

