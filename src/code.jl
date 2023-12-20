# Main code used for the plots and analysis
# AUTHOR: Emil Olszewski
# ==================================================================================================

######## 
# LIBS #
########

using DataFrames
using GLM
using Plots
using CSV
using Statistics
using Random
using LaTeXStrings
using .Utils

# ==================================================================================================
################
# DATA LOADING #
################
# ==================================================================================================

# Load data
sample = DataFrame(CSV.File(".\\data\\sample.csv"))

# Plot total vs bodyweight
Utils.plot_total(sample)

# Plot all the lifts vs bodyweight
Utils.plot_all(sample, size=(800, 600))

# ==================================================================================================
##########################
# SAMPLE TRANSFORMATIONS # 
##########################
# ==================================================================================================

# Take mean of total, bench, squat, deadlift for each bodyweight
#* Po uśrednieniu zostajemy z lekko poand 4000 tysiącami obserwacji z początkowych 40_000. 
averaged_sample = combine(
    groupby(sample, :BodyweightKg),
    :TotalKg         => mean => :TotalKg,
    :Best3BenchKg    => mean => :Best3BenchKg,
    :Best3SquatKg    => mean => :Best3SquatKg,
    :Best3DeadliftKg => mean => :Best3DeadliftKg
)

ma_sample = Utils.moving_average_rows(averaged_sample, :BodyweightKg, 10)


#* Na wykresie widać, że dla wszystkich bojów zależność nie jest liniowa. Wypłaszczanie się krzywej dla większych wartości 
#* bodyweight może wskazywać na zależność logarytmiczną bądź potęgową. 
Utils.plot_all(ma_sample, size=(800, 600))

#* Nałożenie skali logarytmicznej na oś x powoduje `wyprostowanie` się krzywych. Przesłanka na zależnośc logarytmiczną. 
Utils.plot_all(ma_sample, size=(800, 600), xaxis=:ln)

#* Nałożenie skali logarytmicznej na obie osi już nie daje tak dobrych rezultatów. Zakładamy, że zależność jest bliżej 
#* logarytmicznej niż potęgowej.
Utils.plot_all(ma_sample, size=(800, 600), xaxis=:ln, yaxis=:ln)


# Transformacja logarytmiczna danych 
transformed_sample = copy(ma_sample)
transformed_sample[!, :BodyweightKg] = log.(transformed_sample[!, :BodyweightKg])

#* Wykres danych po zastosowaniu transformacji logarytmicznej.
Utils.plot_all(transformed_sample, size=(800, 600))

#* Z wykresu widać, że dla x > 5 (bodyweight > 148) dostajemy dużo szumu. Tym samym możemu obciąć te obserwacje 
#* celem lepszego dopasowania modelu. 
transformed_sample = transformed_sample[transformed_sample[!, :BodyweightKg] .< 5, :]
ma_sample = ma_sample[ma_sample[!, :BodyweightKg] .< exp(5), :]


# ==================================================================================================
#####################
# LINEAR REGRESSION #
#####################
# ==================================================================================================

# fit linear model
linmodel_total = lm(@formula(TotalKg ~ BodyweightKg), transformed_sample)
linmodel_bench = lm(@formula(Best3BenchKg ~ BodyweightKg), transformed_sample)
linmodel_squat = lm(@formula(Best3SquatKg ~ BodyweightKg), transformed_sample)
linmodel_deadlift = lm(@formula(Best3DeadliftKg ~ BodyweightKg), transformed_sample)

total_plot = Utils.plot_total(transformed_sample, size=(800, 600));
plot!(total_plot, transformed_sample[!, :BodyweightKg], predict(linmodel_total), label = "Linear Model", linewidth = 2)

Utils.plot_all_with_models(
    transformed_sample, 
    [linmodel_total, linmodel_bench, linmodel_squat, linmodel_deadlift],
    size=(800, 600)
)

org_total_plot = Utils.plot_total(ma_sample, size=(800, 600));
plot!(org_total_plot, ma_sample[!, :BodyweightKg], coef(linmodel_total)[1] .+ coef(linmodel_total)[2] .* log.(ma_sample[!, :BodyweightKg]), label = "Log Model", linewidth = 2)

# Total histogram
histogram(
    sample[!, :TotalKg], 
    xlabel = "Total (kg)", 
    ylabel = "Frequency", 
    title = "Histogram of Total (kg)", 
    bins = 50,
    normalize= :pdf
)

# Bodyweight histogram
histogram(
    sample[!, :BodyweightKg],
    xlabel = "Bodyweight (kg)",
    ylabel = "Frequency",
    title = "Histogram of Bodyweight (kg)",
    bins = 50,
    normalize= :pdf
)

plot_total(sample)





