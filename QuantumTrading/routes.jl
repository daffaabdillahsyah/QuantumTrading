using HTTP
using Sockets
using JSON3
include("src/QuantumTrade.jl")  # Include the QuantumTrading module
using .QuantumTrading: get_stock_data, generate_signals  # Import the necessary functions

function handle_request(req::HTTP.Request)
    target_path = String(req.target)  # Extract the path as a string

    if target_path == "/"
        html_content = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Quantum Trading Signals</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }
                h1 { text-align: center; }
                table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                table, th, td { border: 1px solid black; }
                th, td { padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
                .no-data { text-align: center; font-weight: bold; color: red; }
            </style>
        </head>
        <body>
            <h1>Quantum Trading Signals</h1>

            <h2>Buy Signals</h2>
            <table id="buy-signals-table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Buy signals will be inserted here -->
                </tbody>
            </table>
            <div id="buy-no-data" class="no-data" style="display: none;">No Buy Signals Available</div>

            <h2>Sell Signals</h2>
            <table id="sell-signals-table">
                <thead>
                    <tr>
                        <th>Timestamp</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Sell signals will be inserted here -->
                </tbody>
            </table>
            <div id="sell-no-data" class="no-data" style="display: none;">No Sell Signals Available</div>

            <script>
                // Fetch stock data from the API
                fetch('/api/stock_data')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Received data:', data); // Debugging line
                        const buySignalsTable = document.getElementById('buy-signals-table').getElementsByTagName('tbody')[0];
                        const sellSignalsTable = document.getElementById('sell-signals-table').getElementsByTagName('tbody')[0];

                        // Populate the Buy Signals table
                        if (data.buy_signals && data.buy_signals.length > 0) {
                            data.buy_signals.forEach(signal => {
                                const row = buySignalsTable.insertRow();
                                const timestampCell = row.insertCell(0);
                                const actionCell = row.insertCell(1);
                                timestampCell.textContent = signal[0];
                                actionCell.textContent = signal[1];
                            });
                        } else {
                            document.getElementById('buy-no-data').style.display = 'block';
                        }

                        // Populate the Sell Signals table
                        if (data.sell_signals && data.sell_signals.length > 0) {
                            data.sell_signals.forEach(signal => {
                                const row = sellSignalsTable.insertRow();
                                const timestampCell = row.insertCell(0);
                                const actionCell = row.insertCell(1);
                                timestampCell.textContent = signal[0];
                                actionCell.textContent = signal[1];
                            });
                        } else {
                            document.getElementById('sell-no-data').style.display = 'block';
                        }
                    })
                    .catch(error => console.error('Error fetching stock data:', error));
            </script>
        </body>
        </html>
        """
        return HTTP.Response(200, html_content)
    elseif target_path == "/api/stock_data"
        stock_data = get_stock_data("AAPL", "your_api_key")  # Replace "your_api_key" with your actual API key
        buy_signals, sell_signals = generate_signals(stock_data)
        response_data = Dict("buy_signals" => buy_signals, "sell_signals" => sell_signals)
        stock_data_json = JSON3.write(response_data)
        return HTTP.Response(200, stock_data_json)
    else
        return HTTP.Response(404, "Not Found")
    end
end

# Start the HTTP server
HTTP.serve(handle_request, Sockets.localhost, 8000)
