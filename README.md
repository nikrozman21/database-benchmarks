# Database Performance Testing

This project is designed to automate the performance testing of a database server using Sysbench. It collects server specifications, parses Sysbench output files, and presents the results in a structured format.

## Features
* Collects server specifications, including CPU model, core count, and total memory.
* Parses Sysbench output files to extract performance metrics (Requests Per Second - RPS) for various tests.
* Groups results by hardware configuration (CPU cores and RAM).
* Displays results in a clear, organized format.

## Requirements
- Python 3.x
- `psutil` library (install via `pip3 install psutil`)

## Usage
1. Ensure you have Python 3 and the necessary libraries installed.
2. Run `docker compose up -d --build` and let it run until the Sysbench container exits.
3. Run the script to process the output files and display results:
`python3 scripts/process.py`

## Example Output
```
-----
Server Specifications:
CPU Model: AMD Ryzen 8 1234F
Core Count: 9
Total Memory: 18 GB
-----
HW: 4c/4g, Test: read-write, RPS: 9627.83
HW: 4c/4g, Test: read-write-large, RPS: 9459.57
-----
HW: 8c/8g, Test: read-write-log, RPS: 22060.30
HW: 8c/8g, Test: memory-heavy-log, RPS: 0.00
-----
```