using CairoMakie, DSP

function generate_data(outer_buffer, te_llzo, cu_llzo, lzo; length=100, gauss_ratio=0.1)
    # Ensure length is odd for symmetry
    length = length % 2 == 0 ? length + 1 : length

    # Calculate total ratio
    total_ratio = outer_buffer + te_llzo + cu_llzo + lzo

    # Calculate number of elements for each layer
    half_length = (length - 1) ÷ 2
    outer_buffer_count = round(Int, outer_buffer / total_ratio * half_length)
    te_llzo_count = round(Int, te_llzo / total_ratio * half_length)
    cu_llzo_count = round(Int, cu_llzo / total_ratio * half_length)
    lzo_count = half_length - outer_buffer_count - te_llzo_count - cu_llzo_count

    # Create the data vector
    data = zeros(length)

    # Initialize transitions array
    transitions = Int[]

    # Fill the first half and record transitions
    start_idx = outer_buffer_count + 1
    push!(transitions, start_idx)
    data[start_idx:start_idx+te_llzo_count-1] .= 7
    start_idx += te_llzo_count
    push!(transitions, start_idx)
    data[start_idx:start_idx+cu_llzo_count-1] .= 6.25
    push!(transitions, start_idx + cu_llzo_count)

    # Fill the second half (mirror of the first half) and record transitions
    push!(transitions, length - outer_buffer_count - te_llzo_count - cu_llzo_count + 1)
    data[end-outer_buffer_count-te_llzo_count-cu_llzo_count+1:end-outer_buffer_count-te_llzo_count] .= 6.25
    push!(transitions, length - outer_buffer_count - te_llzo_count + 1)
    data[end-outer_buffer_count-te_llzo_count+1:end-outer_buffer_count] .= 7
    push!(transitions, length - outer_buffer_count + 1)

    gauss_kernal = [exp(-x^2) for x in range(-2, 2, round(Int, length * gauss_ratio))]
    gauss_kernal /= sum(gauss_kernal)

    data = conv(data, gauss_kernal)

    return data, transitions .+ (length * gauss_ratio / 2)
end

function llzo_plot(;
    outer_buffer=10,
    te_llzo=10,
    cu_llzo=30,
    lzo=15,
    length=1000,
    gauss_ratio=0.08
)

    outer_buffer = 10
    te_llzo = 10
    cu_llzo = 30
    lzo = 15

    data_1, transitions = generate_data(outer_buffer, te_llzo, cu_llzo, lzo; length=1000, gauss_ratio=0.08)

    # Create the figure and axis
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], xlabel="Position", ylabel="Value")

    # Plot the data
    lines!(ax, data_1)

    # Add vertical lines
    vlines!(ax, transitions, color=:black, linestyle=:dash)

    # Add region labels
    text!(ax, (transitions[1] + transitions[2]) / 2, 5, text="TE-LLZO", rotation=π / 2, align=(:center, :bottom))
    text!(ax, (transitions[2] + transitions[3]) / 2, 5, text="Cu-LLZO", rotation=π / 2, align=(:center, :bottom))
    text!(ax, (transitions[3] + transitions[4]) / 2, 5, text="LZO", rotation=π / 2, align=(:center, :bottom))
    text!(ax, (transitions[4] + transitions[5]) / 2, 5, text="Cu-LLZO", rotation=π / 2, align=(:center, :bottom))
    text!(ax, (transitions[5] + transitions[6]) / 2, 5, text="TE-LLZO", rotation=π / 2, align=(:center, :bottom))

    # Show the plot
    return fig
end

fig = llzo_plot()
fig