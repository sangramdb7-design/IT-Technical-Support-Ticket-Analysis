# 📊 Enterprise IT Service Desk & SLA Bottleneck Analytics

**Dataset Used:** [Kaggle - IT Support Tickets (100K)](https://www.kaggle.com/datasets/ahsanneural/synthetic-it-support-tickets)

**📄 [View the Full Executive Presentation](https://portfolio-sangram.vercel.app/project_1)**

## 📝 Problem Statement
Enterprise IT service desks manage high volumes of multi-channel support tickets. Despite having dedicated support queues, operations leadership faces recurring SLA (Service Level Agreement) breach spikes, elevated ticket reopen rates, and delayed resolution times. 

This project analyzes a massive **100,000-row real-world dataset** to find the root causes of these delays. Using **MySQL** as the primary tool, I built an end-to-end data pipeline to track ticket volumes, identify the worst-performing shifts, and pinpoint exactly where bottlenecks occur to improve customer satisfaction (CSAT) and optimize staffing.

## 🛠️ Tools & Technologies
* **MySQL (Core Analysis):** 200+ lines of production code, engineered 14 dedicated analytical views, aggregated metrics, and utilized text-matching for root-cause grouping.
* **Excel Power Query:** Handled initial data cleaning, deduplication, text casing standardization, and timestamp formatting prior to database import.

## 🔍 Key Findings
1. 🌙 **The Night Shift Bottleneck:** The Night shift suffers a staggering **77.09% SLA breach rate** (especially during the 03:00–07:00 handover window) due to a lack of dedicated technical staff.
2. ⚠️ **Premium Tier Failures:** High-paying Platinum plans miss their deadlines **94% of the time** because urgent tickets get stuck in general triage instead of being prioritized.
3. 🔐 **Top Root Causes:** Login/Authentication and API integration issues alone drive over **22,000 missed deadlines**.
4. 🔄 **Reopen Penalties:** Tickets that are reopened take an average of 52.4 hours to resolve—nearly 20 hours longer than tickets fixed on the first try.

## 💡 Actionable Recommendations
Based on the SQL analysis, I recommend a 3-step operations strategy for leadership:
* **Night Shift Specialist Reallocation:** Move 3-5 dedicated L2 technical specialists to off-peak night hours to unblock technical tickets before the morning rush.
* **Premium Tier Fast-Track Routing:** Implement automated routing rules that bypass general L1 queues and send Platinum/Gold tickets directly to senior L2/L3 engineers.
* **Self-Service Automation:** Deploy automated password reset flows and webhook validation tooling to deflect up to 20% of repetitive, high-volume ticket types (Login/API).

## 📂 Repository Structure
* `SQL_data_setup.sql`: Table creation and data import scripts.
* `SQL_business_queries.sql`: The 14 analytical queries and engineered views used to extract insights.
* `IT_Support_Ticket_Analysis_LinkedIn_Carousel.pdf`: Visual case study and slide deck for non-technical stakeholders.
