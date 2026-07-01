# Backend API Specification Add-on: Saving Category Feature

This document outlines the required database schema additions and endpoint updates to support the new **Saving Category** feature.

---

## 1. Database Schema Additions (`categories` table)

The following columns must be added to the `categories` table. All new columns must be **nullable**, as they are only populated when the category `type` is `"saving"`.

| Column | Type | Nullable | Default | Description / Example |
| :--- | :--- | :--- | :--- | :--- |
| `saving_goal_amount` | Decimal(10, 2) | Yes | `NULL` | The total savings target. e.g. `5000.00` |
| `saving_current_amount` | Decimal(10, 2) | Yes | `0.00` | The amount already saved. e.g. `1200.00` |
| `saving_target_date` | Date | Yes | `NULL` | Goal completion deadline (`YYYY-MM-DD`). e.g. `"2026-12-31"` |
| `saving_frequency` | Enum / Varchar | Yes | `NULL` | Saving cadence: `daily`, `weekly`, or `monthly`. |
| `saving_frequency_amount`| Decimal(10, 2) | Yes | `NULL` | Auto-calculated amount required per saving frequency interval. |
| `saving_completion_percentage`| Decimal(5, 1) | Yes | `NULL` | Progress percentage (calculated value between `0.0` and `100.0`). |
| `saving_icon` | Varchar(50) | Yes | `NULL` | Chosen icon selector: `medical`, `car`, `house`, `travel`. |

---

## 2. API Endpoints

### 🔹 GET `/api/categories`
Returns all categories. Must include categories of `type: "saving"`, with saving-specific columns fully populated.

#### Example Response:
```json
[
  {
    "id": 1,
    "name": "Salary",
    "type": "income",
    "created_at": "2026-06-06T14:10:56.000000Z",
    "updated_at": "2026-06-06T14:10:56.000000Z"
  },
  {
    "id": 8,
    "name": "Medical Saving",
    "type": "saving",
    "saving_goal_amount": 5000.00,
    "saving_current_amount": 1200.00,
    "saving_target_date": "2026-12-31",
    "saving_frequency": "monthly",
    "saving_frequency_amount": 625.00,
    "saving_completion_percentage": 24.0,
    "saving_icon": "medical",
    "created_at": "2026-06-14T16:32:26.000000Z",
    "updated_at": "2026-06-14T16:36:07.000000Z"
  }
]
```

---

### 🔹 GET `/api/categories?type=saving`
Filters and returns **only** categories of type `"saving"`.

---

### 🔹 POST `/api/categories`
Creates a new category. Accepts the saving properties inside the JSON body when `type` is `"saving"`.

#### Example Request:
```json
{
  "name": "Summer Trip Saving",
  "type": "saving",
  "saving_goal_amount": 3000.00,
  "saving_current_amount": 300.00,
  "saving_target_date": "2026-10-31",
  "saving_frequency": "monthly",
  "saving_frequency_amount": 675.00,
  "saving_completion_percentage": 10.0,
  "saving_icon": "travel"
}
```

---

### 🔹 PUT `/api/categories/{id}`
Updates category name, type, or saving targets.

#### Example Request:
```json
{
  "name": "Summer Trip Saving",
  "type": "saving",
  "saving_goal_amount": 3000.00,
  "saving_current_amount": 600.00,
  "saving_target_date": "2026-10-31",
  "saving_frequency": "monthly",
  "saving_frequency_amount": 600.00,
  "saving_completion_percentage": 20.0,
  "saving_icon": "travel"
}
```

---

## 3. Auto-Calculation Business Logic (Recommended for Backend)

Although the mobile app calculates and submits these values, the backend should validate or recalculate these properties on inserts/updates to keep database integrity:

### 1. Progress Percentage
$$\text{saving\_completion\_percentage} = \min\left(\left(\frac{\text{saving\_current\_amount}}{\text{saving\_goal\_amount}}\right) \times 100, 100.0\right)$$

### 2. Frequency Amount Calculation
Based on the current date and the target date:
* **daily**:
  $$\text{saving\_frequency\_amount} = \frac{\text{saving\_goal\_amount}}{\text{number\_of\_days\_until\_target\_date}}$$
* **weekly**:
  $$\text{saving\_frequency\_amount} = \frac{\text{saving\_goal\_amount}}{\text{number\_of\_weeks\_until\_target\_date}}$$
* **monthly**:
  $$\text{saving\_frequency\_amount} = \frac{\text{saving\_goal\_amount}}{\text{number\_of\_months\_until\_target\_date}}$$
