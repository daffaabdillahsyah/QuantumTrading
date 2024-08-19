using HTTP, DataFrames, CSV, Statistics

function get_stock_data(symbol::String, api_key::String)
    url = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=$(symbol)&interval=5min&apikey=$(api_key)&datatype=csv"
    response = HTTP.get(url)
    data = CSV.File(IOBuffer(response.body)) |> DataFrame
    return data
end

function moving_average(data::DataFrame, window::Int)
    ma = DataFrame(MovingAverage=Array{Float64,1}(undef, nrow(data)))
    for i in window:nrow(data)
        ma.MovingAverage[i] = mean(data[i-window+1:i, :close])
    end
    return ma
end

function generate_signals(data::DataFrame)
    buy_signals = []
    sell_signals = []
    for i in 2:nrow(data)
        if data[i, :close] > data[i-1, :close]
            push!(buy_signals, (data[i, :timestamp], "BUY"))
        elseif data[i, :close] < data[i-1, :close]
            push!(sell_signals, (data[i, :timestamp], "SELL"))
        end
    end
    return buy_signals, sell_signals
end

function main()
    api_key = "your_alpha_vantage_api_key"
    stock_data = get_stock_data("AAPL", api_key)
    println("Stock Data: ", stock_data)

    ma_data = moving_average(stock_data, 5)
    println("Moving Average Data: ", ma_data)

    buy_signals, sell_signals = generate_signals(stock_data)
    println("Buy Signals: ", buy_signals)
    println("Sell Signals: ", sell_signals)
end

main()
