
# TODO : in this file, some functions for matrices and vectors are defined just to make other files work,
# such as forms.jl, transform_form.jl, linear_conjugate.jl and linear_centralizer.jl
# TODO : functions in this file are only temporarily, and often inefficient.
# TODO: once similar working methods are defined in other files or packages (e.g. Hecke),
# functions in this file are to be removed / moved / replaced
# TODO: when this happens, files mentioned above need to be modified too.




########################################################################
#
# Matrix manipulation
#
########################################################################


"""
    matrix(A::Vector{AbstractAlgebra.Generic.FreeModuleElem})

Return the matrix whose rows are the vectors in `A`.
All vectors in `A` must have the same length and the same base ring.
"""
function matrix(A::Vector{AbstractAlgebra.Generic.FreeModuleElem{T}}) where T <: RingElem
   c = length(A[1].v)
   @assert all(x -> length(x.v)==c, A) "Vectors must have the same length"
   X = zero_matrix(base_ring(A[1]), length(A), c)
   for i in 1:length(A), j in 1:c
      X[i,j] = A[i][j]
   end

   return X
end

"""
    conjugate_transpose(x::MatElem{T}) where T <: FinFieldElem

If the base ring of `x` is `GF(q^2)`, return the matrix `transpose( map ( y -> y^q, x) )`.
An exception is thrown if the base ring does not have even degree.
"""
function conjugate_transpose(x::MatElem{T}) where T <: FinFieldElem
  e = degree(base_ring(x))
  @req iseven(e) "The base ring must have even degree"
  e = div(e, 2)

  y = similar(x, ncols(x), nrows(x))
  for i in 1:ncols(x), j in 1:nrows(x)
    # This code could be *much* faster, by precomputing the Frobenius map
    # once; see also FrobeniusCtx in Hecke (but that does not yet support all
    # finite field types at the time this comment was written).
    # If you need this function to be faster, talk to Claus or Max.
    y[i,j] = frobenius(x[j,i],e)
  end
  return y
end


"""
    complement(V::AbstractAlgebra.Generic.FreeModule{T}, W::AbstractAlgebra.Generic.Submodule{T}) where T <: FieldElem

Return a complement for `W` in `V`, i.e. a subspace `U` of `V` such that `V` is
the direct sum of `U` and `W`.
"""
function complement(V::AbstractAlgebra.Generic.FreeModule{T}, W::AbstractAlgebra.Generic.Submodule{T}) where T <: FieldElem
   @assert is_submodule(V,W) "The second argument is not a subspace of the first one"
   if vector_space_dim(W)==0 return sub(V,basis(V)) end

   e = W.map

   H = matrix( vcat([e(g) for g in gens(W)], [zero(V) for i in 1:(vector_space_dim(V)-vector_space_dim(W)) ]) )
   A_left = identity_matrix(base_ring(V), vector_space_dim(V))
   A_right = identity_matrix(base_ring(V), vector_space_dim(V))
   for rn in 1:vector_space_dim(W)     # rn = row number
      cn = rn    # column number
      while H[rn,cn]==0 cn+=1 end   # bring on the left the first non-zero entry
      swap_cols!(H,rn,cn)
      swap_rows!(A_right,rn,cn)
      for j in rn+1:vector_space_dim(W)
         add_row!(H,H[j,rn]*H[rn,rn]^-1,rn,j)
         add_column!(A_left,A_left[j,rn]*A_left[rn,rn]^-1,j,rn)
      end
   end
   for j in vector_space_dim(W)+1:vector_space_dim(V)  H[j,j]=1  end
   H = A_left*H*A_right
   _gens = [V([H[i,j] for j in 1:vector_space_dim(V)]) for i in vector_space_dim(W)+1:vector_space_dim(V) ]

   return sub(V,_gens)
end

"""
    permutation_matrix(F::Ring, Q::AbstractVector{T}) where T <: Int
    permutation_matrix(F::Ring, p::PermGroupElem)

Return the permutation matrix over the ring `R` corresponding to the sequence `Q` or to the permutation `p`.
If `Q` is a sequence, then `Q` must contain exactly once every integer from 1 to some `n`.

# Examples
```jldoctest
julia> s = perm([3,1,2])
(1,3,2)

julia> permutation_matrix(QQ,s)
[0   0   1]
[1   0   0]
[0   1   0]

```
"""
function permutation_matrix(F::Ring, Q::AbstractVector{<:IntegerUnion})
   @assert Set(Q)==Set(1:length(Q)) "Invalid input"
   Z = zero_matrix(F,length(Q),length(Q))
   for i in 1:length(Q) Z[i,Q[i]] = 1 end
   return Z
end

permutation_matrix(F::Ring, p::PermGroupElem) = permutation_matrix(F, Vector(p))

########################################################################
#
# New properties
#
########################################################################

# TODO: Move to AbstractAlgebra

"""
    is_hermitian(B::MatElem{T}) where T <: FinFieldElem

Return whether the matrix `B` is hermitian, i.e. `B = conjugate_transpose(B)`.
Return `false` if `B` is not a square matrix, or the field has not even degree.
"""
function is_hermitian(B::MatElem{T}) where T <: FinFieldElem
   n = nrows(B)
   n == ncols(B) || return false
   e = degree(base_ring(B))
   iseven(e) ? e = div(e,2) : return false

   for i in 1:n, j in i:n
      B[i,j] == frobenius(B[j,i],e) || return false
   end

   return true
end

# return (true, h) if y = hx, (false, nothing) otherwise
# FIXME: at the moment, works only for fields
function _is_scalar_multiple_mat(x::MatElem{T}, y::MatElem{T}) where T <: RingElem
   F=base_ring(x)
   F==base_ring(y) || return (false, nothing)
   nrows(x)==nrows(y) || return (false, nothing)
   ncols(x)==ncols(y) || return (false, nothing)

   for i in 1:nrows(x), j in 1:ncols(x)
      if !iszero(x[i,j])
         h = y[i,j] * x[i,j]^-1
         return y == h*x ? (true,h) : (false, nothing)
      end
   end

   # at this point, x must be zero
   return y == 0 ? (true, F(1)) : (false, nothing)
end

########################################################################
#
# New operations
#
########################################################################

Base.:*(v::AbstractAlgebra.Generic.FreeModuleElem{T},x::MatrixGroupElem{T}) where T <: RingElem = v.parent(v.v*matrix(x))

Base.:*(v::Vector{T}, x::MatrixGroupElem{T}) where T <: RingElem = v*matrix(x)
Base.:*(x::MatrixGroupElem{T}, u::Vector{T}) where T <: RingElem = matrix(x)*u

# `on_tuples` and `on_sets` delegate to an action via `^` on the subobjects
# (`^` is the natural action in GAP)
Base.:^(v::AbstractAlgebra.Generic.FreeModuleElem{T},x::MatrixGroupElem{T}) where T <: RingElem = v.parent(v.v*matrix(x))

# action of matrix group elements on subspaces of a vector space
function Base.:^(V::AbstractAlgebra.Generic.Submodule{T}, x::MatrixGroupElem{T}) where T <: RingElem
  return sub(V.m, [v^x for v in V.gens])[1]
end
