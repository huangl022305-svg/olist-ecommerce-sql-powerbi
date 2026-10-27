# E-Commerce Analytics | SQL & Power BI

**An end-to-end data analytics project exploring sales performance, delivery efficiency, and customer satisfaction using real-world e-commerce data.**

**Tech Stack:** PostgreSQL · SQL · Power BI · DAX

**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## 1. Project Overview

This project analyzes approximately **100,000 e-commerce orders from 2016–2018** to investigate three key business questions:

- How are sales distributed across time, product categories, and geographic regions?
- Which regions experience the most delivery delays?
- How is delivery performance associated with customer satisfaction?

Using **PostgreSQL**, I integrated six relational tables, performed SQL-based analysis, and created analytical views for reporting. I then developed two interactive **Power BI dashboards** to visualize key performance indicators and communicate actionable business insights.

## 2. Key Performance Indicators

| KPI | Result |
|---|---:|
| Total Merchandise Sales | **R$13.22M** |
| Delivered Orders | **96,478** |
| Order Item Records | 110,197 |
| Average Order Value | R$137.04 |
| Late Delivery Rate | **6.77%** |
| Average Delivery Time | 12.5 days |

*Sales figures represent merchandise value from delivered orders, excluding freight. Currency: Brazilian Real (BRL).*

## 3. Power BI Dashboards

### Dashboard 1 — Sales Performance Overview

The Sales Overview dashboard provides an overview of the company's historical sales performance.

**Key Visualizations:**
- Total Sales, Orders, Items, and Average Order Value
- Monthly Sales Revenue Trends
- Top 10 Product Categories by Revenue
- Top 10 States by Revenue

**Highlights:**

São Paulo generated approximately **R$5.1 million** in merchandise sales, making it the largest regional market.

Health & Beauty was the highest-revenue product category, generating approximately **R$1.23 million**.

### Dashboard 2 — Delivery Performance & Customer Experience

This dashboard examines delivery reliability and its relationship with customer satisfaction.

**Key Visualizations:**
- Late Delivery Rate and Average Delivery Time
- Average Review Score by Delivery Status
- Low Rating Rate by Delivery Status
- Top 10 States by Late Deliveries

**Highlights:**

| Metric | On-Time | Late |
|---|---:|---:|
| Average Review Score | 4.29 / 5 | 2.27 / 5 |
| Low Rating Rate (1–2 Stars) | 9.27% | 62.42% |

Delayed deliveries were associated with substantially worse customer ratings, identifying delivery reliability as a potential priority for operational improvement.

**[View Dashboard Screenshots](screenshots/)**

## 4. SQL Analysis & Technical Implementation

### Database Preparation

Imported and analyzed six relational datasets containing:

- Customer information
- Order transactions
- Order items and prices
- Product information
- Product category translations
- Customer reviews

### SQL Techniques

| Technique | Application |
|---|---|
| JOIN / LEFT JOIN | Integrated related transactional tables |
| GROUP BY / Aggregations | Calculated sales KPIs and regional performance |
| CTEs | Structured multi-step analytical queries |
| LAG() | Calculated month-over-month revenue growth |
| ROW_NUMBER() | Selected one review per order for analysis |
| CASE WHEN | Classified delivery performance |
| SQL Views | Prepared reusable datasets for Power BI |

### SQL Views Created

**`vw_order_performance`**

An order-level analytical dataset integrating sales, customer location, delivery performance, and review scores.

**`vw_category_sales`**

An aggregated dataset supporting revenue analysis by month, geographic region, and product category.

These views were connected directly to Power BI, where DAX measures were used to calculate and visualize business KPIs.

## 5. Key Business Insights

### Finding 1 — Geographic Sales Concentration

São Paulo accounted for approximately R$5.1M in merchandise sales, significantly exceeding other states in the dataset.

**Business implication:** Regional sales concentration highlights the importance of maintaining operational performance in high-volume markets.

### Finding 2 — Delivery Reliability and Customer Satisfaction

- On-time orders received an average rating of **4.29/5**.
- Late deliveries received an average rating of **2.27/5**.
- Low-rating frequency increased from **9.27% to 62.42%** for late deliveries.

**Business implication:** Improving delivery reliability may help address customer dissatisfaction.

### Finding 3 — Regional Delivery Challenges

São Paulo recorded **1,820 late deliveries**, followed by Rio de Janeiro with **1,495**.

However, regions with the greatest number of delays do not necessarily have the highest late-delivery rates.

**Business implication:** Logistics performance should be evaluated using both absolute delay counts and delay rates.

## 6. Business Recommendations

**1. Prioritize Delivery Reliability**

Investigate recurring delivery delays, particularly in high-volume markets where operational improvements could affect more customers.

**2. Monitor Customer Satisfaction Alongside Logistics KPIs**

Track delivery performance and customer reviews together to identify potential service-quality issues.

**3. Improve Regional Performance Monitoring**

Use Power BI dashboards to compare revenue, order volume, and delivery efficiency across geographic markets.

## 7. Repository Structure

| Folder | Contents |
|---|---|
| [sql/](sql/) | SQL queries, data analysis, and analytical views |
| [powerBI/](powerBI/) | Power BI Desktop report (.pbix) |
| [screenshots/](screenshots/) | Dashboard screenshots |
| README.md | Project documentation and findings |

## 8. Data Limitations

- The dataset covers historical transactions from 2016–2018 and does not represent current business performance.
- Merchandise sales exclude shipping fees and should not be interpreted as net profit.
- Some beginning and ending months have limited coverage.
- Delivery performance and customer ratings are observational data. The identified relationships do not establish causation.

---

**Project Focus:** SQL Data Analysis · Business Intelligence · Data Visualization · Operational Analytics
