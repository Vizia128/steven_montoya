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

    # Fill the first half
    start_idx = outer_buffer_count + 1
    data[start_idx:start_idx+te_llzo_count-1] .= 7
    start_idx += te_llzo_count
    data[start_idx:start_idx+cu_llzo_count-1] .= 6.25

    # Fill the second half (mirror of the first half)
    data[end-outer_buffer_count+1:end] .= 0
    data[end-outer_buffer_count-te_llzo_count+1:end-outer_buffer_count] .= 7
    data[end-outer_buffer_count-te_llzo_count-cu_llzo_count+1:end-outer_buffer_count-te_llzo_count] .= 6.25

    gauss_kernal = [exp(-x^2) for x in range(-2, 2, round(Int, length * gauss_ratio))]
    @show length / gauss_ratio
    gauss_kernal /= sum(gauss_kernal)

    data = conv(data, gauss_kernal)

    return data
end

data_1 = generate_data(10, 10, 30, 15; length=1000, gauss_ratio=0.15)
lines(data_1)