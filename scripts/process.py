import os
import re
import psutil
import subprocess

def get_server_specs():
    # Get CPU model
    cpu_info = subprocess.run(['lscpu'], capture_output=True, text=True)
    cpu_model = ''
    for line in cpu_info.stdout.splitlines():
        if 'Model name' in line:
            cpu_model = line.split(':')[1].strip()

    # Get core count and total memory
    core_count = psutil.cpu_count(logical=True)
    total_memory = psutil.virtual_memory().total / (1024 ** 3)  # Convert to GB

    return cpu_model, core_count, total_memory

def parse_sysbench_output(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    
    # Extract RPS value
    rps_match = re.search(r'queries:\s+\d+\s+\(([\d.]+) per sec\.\)', content)
    rps_value = rps_match.group(1) if rps_match else 'N/A'
    
    # Get the test name
    test_name = os.path.basename(file_path).rsplit('-', 2)[0]
    
    return test_name, float(rps_value) if rps_value != 'N/A' else 0

def main():
    # Collect server specifications
    cpu_model, core_count, total_memory = get_server_specs()
    print("-----")
    print(f"Server Specifications:")
    print(f"CPU Model: {cpu_model}")
    print(f"Core Count: {core_count}")
    print(f"Total Memory: {total_memory:.2f} GB")
    print("-----")

    # Process the output files
    base_directory = 'output'
    results = {}
    
    for file_name in os.listdir(base_directory):
        if file_name.endswith('.txt'):
            file_path = os.path.join(base_directory, file_name)
            test_name, rps_value = parse_sysbench_output(file_path)

            # Extract hardware configuration from the filename
            hw_config = re.search(r'(\d+)cpu-(\d+)gb', file_name)
            if hw_config:
                cpu = hw_config.group(1)
                ram = hw_config.group(2)
                hw_key = f'{cpu}c/{ram}g'

                if hw_key not in results:
                    results[hw_key] = []
                results[hw_key].append((test_name, rps_value))

    # Display the results
    for hw_key, test_results in results.items():
        for test_name, rps_value in test_results:
            print(f"HW: {hw_key}, Test: {test_name}, RPS: {rps_value:.2f}")
        print("-----")

if __name__ == "__main__":
    main()
