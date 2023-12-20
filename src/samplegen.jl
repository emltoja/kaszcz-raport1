using DataFrames
using CSV

# Take random sample of 80_000 lifters
begin
    data = DataFrame(CSV.File(".\\data\\menpwrlf_droppedmissing.csv"))
    data = data[shuffle(1:size(data, 1)), :]
    sample = data[1:80_000, :]
    CSV.write(".\\data\\sample.csv", sample)
end