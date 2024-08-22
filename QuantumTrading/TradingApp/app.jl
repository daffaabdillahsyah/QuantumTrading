module App
# import pagackages and data analysis code
using GenieFramework
using DataFrames
include("stock-analysis.jl")
# set up Genie development environment
@genietools

# add reactive code to make the UI interactive
@app begin
    # @out declares a read-only (from the browser) variable
    @out stocks = ["AAPL", "MSFT", "GOOGL", "^GSPC"]
    # @in declares a read-write (from the browser) variable
    @in selected_stock = "AAPL"
    # floats for big numbers
    @out end_price = 0.0
    @out period_diff = 0.0
    @out percent_return = 0.0
    @out avg_price = 0.0
    # strings for date fields
    @in start_date = "2015-01-01"
    @in end_date = "2023-01-01"
    # DataFrame for the plot
    @out prices = DataFrame(stock=[], close=[], timestamp=[], ma20=[])
    # # the handler watches a list of variables and executes code when they change
    @onchange isready, selected_stock, start_date, end_date begin
        prices = get_prices(selected_stock, startdt=start_date, enddt=end_date) |> DataFrame |> add_ma20!
        end_price, period_diff, percent_return, avg_price = metrics(prices)
    end
end

# register a new route and the page that will be
# loaded on access
@page("/", "app.jl.html")
end