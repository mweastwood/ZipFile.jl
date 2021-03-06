# Writer the content of a into w.
function write{T}(w::WritableFile, a::Array{T})
	# If this is not provided, Base.IO write methods will write
	# arrays one element at a time.
	if isbits(T)
		write(w, pointer(a), length(a)*sizeof(T))
	else
		invoke(write, (IO, Array), w, a)
	end
end

# Writer the content of a into w.
function write{T,N,A<:Array}(w::WritableFile, a::SubArray{T,N,A})
	# This function is copied from Julia base/io.jl
	if !isbits(T) || stride(a,1)!=1
		return invoke(write, (Any, AbstractArray), s, a)
	end
	colsz = size(a,1)*sizeof(T)
	if N<=1
		return write(w, pointer(a, 1), colsz)
	else
		cartesianmap((idxs...)->write(w, pointer(a, idxs), colsz),
			tuple(1, size(a)[2:end]...))
		return colsz*Base.trailingsize(a,2)
	end
end

# Writer the byte b in w.
function write(w::WritableFile, b::Uint8)
	write(w, Uint8[b])
end

# Read and return a byte from f. Throws EOFError if there is no more byte to read.
function read(f::ReadableFile, ::Type{Uint8})
	# This function needs to be fast because readbytes, readall, etc.
	# uses it. Avoid function calls when possible.
	b = Array(Uint8, 1)
	read(f, b)
	b[1]
end
