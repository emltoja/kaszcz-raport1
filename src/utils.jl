# Module containing utility functions for the project
# AUTHOR: Emil Olszewski
# ==================================================================================================

module Utils

    export plot_all, plot_total, plot_squat, plot_bench, plot_deadlift, moving_average_rows

    using DataFrames
    using GLM
    using Plots
    using CSV
    using Statistics
    using Random
    using LaTeXStrings
    
    function plot_squat(sample; kwargs...)
        # Plot best_squat vs bodyweight
        scatter(
            sample[!, :BodyweightKg], sample[!, :Best3SquatKg], 
            xlabel = "Bodyweight (kg)", ylabel = "Squat (kg)",
            title = "Best Squat vs Bodyweight",
            markersize=0.5;
            kwargs...
        )
    end

    function plot_bench(sample; kwargs...)
        # Plot best_bench vs bodyweight
        scatter(
            sample[!, :BodyweightKg], sample[!, :Best3BenchKg], 
            xlabel = "Bodyweight (kg)", ylabel = "Bench (kg)",
            title = "Best Bench vs Bodyweight",
            markersize=0.5;
            kwargs...
        )
    end

    function plot_deadlift(sample; kwargs...)
        # Plot best_deadlift vs bodyweight
        scatter(
            sample[!, :BodyweightKg], sample[!, :Best3DeadliftKg], 
            xlabel = "Bodyweight (kg)", ylabel = "Deadlift (kg)",
            title = "Best Deadlift vs Bodyweight",
            markersize=0.5;
            kwargs...
        )
    end
    
    function plot_total(sample; kwargs...)
        # Plot total vs bodyweight
        scatter(
            sample[!, :BodyweightKg], sample[!, :TotalKg], 
            xlabel = "Bodyweight (kg)", ylabel = "Total (kg)",
            title = "Total vs Bodyweight",
            markersize=0.5;
            kwargs...
        )
    end


    function plot_all(sample; kwargs...)
        # Plot total vs bodyweight
        total_plot = plot_total(sample);

        # Plot best_bench vs bodyweight
        bench_plot = plot_bench(sample);

        # Plot best_squat vs bodyweight
        squat_plot = plot_squat(sample);

        # Plot best_deadlift vs bodyweight
        deadlift_plot = plot_deadlift(sample);

        plot(total_plot, bench_plot, squat_plot, deadlift_plot, layout=(2, 2); kwargs...)

    end


    function plot_all_with_models(sample, models; kwargs...)

        total_model, bench_model, squat_model, deadlift_model = models

        # Plot total vs bodyweight
        total_plot = plot_total(sample);
        plot!(
            total_plot,
            sample[!, :BodyweightKg],
            predict(total_model),
            label = "Linear Model",
            linewidth = 2
        )

        # Plot best_bench vs bodyweight
        bench_plot = plot_bench(sample);
        plot!(
            bench_plot,
            sample[!, :BodyweightKg], 
            predict(bench_model), 
            label = "Linear Model", 
            linewidth = 2
        )

        # Plot best_squat vs bodyweight
        squat_plot = plot_squat(sample);
        plot!(
            squat_plot, 
            sample[!, :BodyweightKg], 
            predict(squat_model), 
            label = "Linear Model", 
            linewidth = 2
        )

        # Plot best_deadlift vs bodyweight
        deadlift_plot = plot_deadlift(sample);
        plot!(
            deadlift_plot, 
            sample[!, :BodyweightKg], 
            predict(deadlift_model), 
            label = "Linear Model", 
            linewidth = 2
        )

        plot(total_plot, bench_plot, squat_plot, deadlift_plot, layout=(2, 2); kwargs...)
    
    end

    
    function moving_average_rows(df::DataFrame, column::Symbol, window::Integer)
        sorted_df = sort(df, column)
        
        for i in axes(sorted_df, 1)
            if i % window == 0
                for j in 1:(window-1)
                    sorted_df[i-j, column] = sorted_df[i, column]
                end
            end
        end
    
        averaged_sample = combine(
            groupby(sorted_df, column),
            :TotalKg         => mean => :TotalKg,
            :Best3BenchKg    => mean => :Best3BenchKg,
            :Best3SquatKg    => mean => :Best3SquatKg,
            :Best3DeadliftKg => mean => :Best3DeadliftKg
        )
    
        return averaged_sample

    end

end