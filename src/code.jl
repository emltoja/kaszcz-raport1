using DataFrames
using GLM
using Plots
using CSV
using Statistics
using Random
using LaTeXStrings

GEN_SAMPLE = true 


if GEN_SAMPLE 
    # Take random sample of 5000 lifters
    data = DataFrame(CSV.File("data_production.csv"))
    data = data[shuffle(1:size(data, 1)), :]
    sample = menpowerlifting[1:5000, :]
    CSV.write("sample.csv", sample)
else 
    sample = DataFrame(CSV.File("sample.csv"))
end


scatter(sample[!, :BodyweightKg], sample[!, :TotalKg], xlabel = "Bodyweight (kg)", ylabel = "Total (kg)", title = "Total vs Bodyweight", markersize=0.5)


# fit linear model
linmodel = lm(@formula(TotalKg ~ BodyweightKg), sample)
# plot linear model
plot!(sample[!, :BodyweightKg], predict(linmodel), label = "Linear Model", linewidth = 2)

histogram(sample[!, :TotalKg], xlabel = "Total (kg)", ylabel = "Frequency", title = "Histogram of Total (kg)", bins = 50, normalize= :pdf)
histogram(sample[!, :BodyweightKg], xlabel = "Bodyweight (kg)", ylabel = "Frequency", title = "Histogram of Bodyweight (kg)", bins = 50, normalize= :pdf)