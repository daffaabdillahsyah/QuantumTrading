using YFinance, DataFrames, Statistics, Dates

function moving_average(df::AbstractDataFrame, column::Symbol, window_size::Int)
    [mean(df[!,column][max(1, i-window_size+1):i]) for i in 1:size(df, 1)]
end

function add_ma20!(prices)
    hcat(prices, DataFrame(:ma20 => moving_average(prices, :close,20)))
end

function metrics(prices)
    end_price = round(prices[!,:close][end], digits=3)
    period_diff = round(prices[!,:close][end] - prices[!,:close][1], digits=3)
    percent_return = round((prices[!,:close][end] - prices[!,:close][1]) / prices[!,:close][1] * 100, digits=3)
    avg_price = round(mean(prices[!,:close]), digits=3)
    (end_price, period_diff, percent_return, avg_price)
end


function main()
    start_date = "2023-01-01"
    end_date = "2024-01-01"
    symbol = "AAPL"
    prices = get_prices(symbol, startdt=start_date, enddt=end_date) |> DataFrame
    add_ma20!(prices)
    end_price, period_diff, percent_return, avg_price = metrics(prices)
    println("Press a key to exit.")
    read(stdin, String)
end
