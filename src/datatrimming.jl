using DataFrames
using CSV

menpowerlifting = DataFrame(CSV.File("menpowerlifting.csv"))
# Remove missing values
dropmissing!(menpowerlifting, :Best3SquatKg)
dropmissing!(menpowerlifting, :Best3BenchKg)
dropmissing!(menpowerlifting, :Best3DeadliftKg)
dropmissing!(menpowerlifting, :BodyweightKg)
dropmissing!(menpowerlifting, :TotalKg)
# Only take lifters aged 16-40
dropmissing!(menpowerlifting, :Age)
menpowerlifting = filter(row -> (row[:Age] >= 16 && row[:Age] <= 40), menpowerlifting)

CSV.write("data_production.csv", menpowerlifting)