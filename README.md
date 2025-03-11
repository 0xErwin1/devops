# 📊 Monitoring with Grafana, InfluxDB, and Telegraf

This repository contains configurations and scripts to deploy a monitoring system based on **Grafana**, **InfluxDB**, and **Telegraf**, using **Docker Compose**. It simplifies the setup and deployment of an automated monitoring environment for both servers and clients.

---

## 🚀 Technologies Used

- **Grafana**: Data visualization and monitoring platform.
- **InfluxDB**: Time-series database for storing metrics.
- **Telegraf**: Metrics collection agent.
- **Docker Compose**: Container orchestration tool to facilitate deployment.

---

## 📊 Available Dashboards

For quick visualization, you can import the following dashboards into Grafana:

- **Docker Monitoring Dashboard**: [ID 17020](https://grafana.com/grafana/dashboards/17020)
- **InfluxDB Monitoring Dashboard**: [ID 15650](https://grafana.com/grafana/dashboards/15650)

---

## 🔧 Installation and Usage

### 📌 Prerequisites

- Docker and Docker Compose installed on the system.
- Access to a server where the services will be deployed.

### ⚙️ Environment Variables Setup

Before running the setup scripts, ensure the following environment variables are properly configured:

#### Client Environment Variables

Set the following environment variables before running the client setup:

- `INFLUX_TOKEN` - Authentication token for InfluxDB (required).
- `INFLUX_ORG` - Organization name in InfluxDB (required).
- `INFLUX_BUCKET` - Name of the bucket to store metrics (required).
- `INFLUX_URL` - URL of the InfluxDB instance (required).

If any of these variables are missing, the setup will terminate with an error.

#### Server Environment Variables

Set the following environment variables before running the server setup:

- `INFLUX_USERNAME` - Admin username for InfluxDB (default: `admin`).
- `INFLUX_PASSWORD` - Admin password for InfluxDB (default: a randomly generated 8-character string).
- `INFLUX_TOKEN` - Authentication token (default: a randomly generated 32-character string).
- `INFLUX_ORG` - Organization name in InfluxDB (default: `ignis`).
- `INFLUX_BUCKET` - Name of the bucket to store metrics (default: `monitoring`).
- `INFLUX_URL` - URL of the InfluxDB instance (default: `http://localhost:8086`).

If these variables are not explicitly set, default values will be used or generated automatically.

### ⚙️ Initial Setup

Before starting the services, you need to run the setup scripts:

1. To configure the server:
   ```sh
   ./init-server.sh
   # Or if you prefer to use Perl
   perl init-server.pl
   ```
2. To configure the client:
   ```sh
   ./init-client.sh
   # Or if you prefer to use Perl
   perl init-client.pl
   ```

### ▶️ Deployment

1. Clone this repository:
   ```sh
   git clone https://github.com/0xErwin1/devops.git
   cd devops
   ```
2. Start the services:
   ```sh
   docker-compose up -d
   ```
3. Access Grafana at `http://localhost:3000` (default username and password: `admin` / `admin`).
4. Configure **InfluxDB** as a data source in Grafana.
5. Import the dashboards mentioned above.

---

## 🛠️ Additional Configuration

- You can customize the configuration files inside the `config/` folder.
- Modify `docker-compose.yml` according to your needs.

---

## 🤝 Contributions

Contributions are welcome! If you have improvements or want to add new configurations, feel free to submit a **pull request** or open an **issue**.

---

## 📜 License

This project is distributed under the **GNU General Public License v3.0 (GPLv3)**.
