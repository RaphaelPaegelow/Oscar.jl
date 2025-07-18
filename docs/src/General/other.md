```@meta
CurrentModule = Oscar
CollapsedDocStrings = true
DocTestSetup = Oscar.doctestsetup()
```

# Notes for users of other computer algebra systems

## General differences

- Julia evaluates `2^100` to `0` because `2` is regarded as a 64 bit integer.
  Write `ZZRingElem(2)^100` to get a long.


## Notes for GAP users

This section describes differences between GAP and Oscar.
(Hints about using GAP in Oscar can be found in the section about
[GAP Integration](@ref).)

- The syntax of the languages is slightly different.

  - In GAP, equality of two objects is checked with `=`,
    and one assigns a value to a variable with `:=`.
    In Julia, equality is checked with `==`,
    and `=` denotes assignment.
    Similarly, inequality of objects is checked with `<>` in GAP
    and with `!=` in Julia.

  - In GAP, the operator `not` is used to negate boolean expressions,
    whereas `!` is used in Julia.

  - In GAP, object identity is checked with the function `IsIdenticalObj`,
    whereas the infix operator `===` (with negation `!==`)
    is used in Julia.

  - In GAP, `if` statements have the form
    ```gap
    if condition1 then
      statements1
    elif condition2 then
      statements2
    else
      statements3
    fi;
    ```
    whereas the Julia syntax is
    ```julia
    if condition1
      statements1
    elseif condition2
      statements2
    else
      statements3
    end
    ```
    Similarly, GAP's `for` loops have the form
    ```gap
    for var in list do
      statements
    od;
    ```
    whereas the Julia syntax is
    ```julia
    for var in list
      statements
    end
    ```
    (The situation with `while` loops is analogous.)

- Also the semantics is slightly different.

  In GAP, the sum of a matrix (a list of lists) and a scalar is defined
  recursively as the pointwise sum.
  ```gap-repl
  gap> [ [ 1, 2 ], [ 3, 4 ] ] + 2;
  [ [ 3, 4 ], [ 5, 6 ] ]
  ```
  In Oscar, the sum of a matrix and a scalar is defined as the sum of
  the given matrix and the multiple of the identity matrix that is given
  by the scalar.
  ```julia-repl
  julia> matrix(ZZ, [1 2; 3 4]) + 2
  [3   2]
  [3   6]
  ```

- The interactive sessions behave differently.

  When an error occurs or when the user hits ctrl-C in a GAP session,
  usually a break loop is entered,
  from which one can either try to continue the computations,
  by entering `return`, or return to the GAP prompt, by entering `quit`;
  in the latter case, some objects may be corrupted afterwards.

  In a Julia session, one gets automatically back to the Julia prompt
  when an error occurs or when the user hits ctrl-C,
  and again some objects may be corrupted afterwards.

- Variable names in GAP and Julia are recommended to be written in
  camel case and snake case, respectively, see [Naming conventions](@ref).
  For example, the GAP function `SylowSubgroup` corresponds to
  Oscar's `sylow_subgroup`.

  Thus the GAP rule that the names of user variables should start with a
  lowercase letter, in order to avoid clashes with system variables,
  does not make sense in Julia.

  Moreover, global Oscar variables are not write protected,
  contrary to most global GAP variables.
  Thus there is always the danger that assignments overwrite Julia functions.
  For example, it is tempting to use `gens`, `hom`, and `map` as names for
  variables, but Julia or Oscar define them already.

  (Also copying some lines of code from an Oscar function into a Julia session
  can be dangerous in this sense,
  because some names of local variables of the function may coincide with the
  names of global variables.)

- GAP provides natural embeddings of many algebraic structures.
  For example, two finite fields of the same characteristic are embedded
  into each other whenever this makes sense, and the elements of the smaller
  field are regarded also as elements of the larger field.
  Analogously, subfields of cyclotomic fields are naturally embedded
  into each other, and in fact their elements are internally represented
  w.r.t. the smallest possible cyclotomic field.

  In Oscar, this is not the case.
  Each element of an algebraic structure has a parent,
  and operations involving several elements (such as arithmetic operations)
  are usually restricted to the situation that their parents coincide.
  One has to explicitly coerce a given element into a different parent
  if necessary.

  The consequences can be quite subtle.
  Each permutation group in Oscar has a fixed degree,
  and the function `is_transitive` checks whether its argument is transitive
  on the points from 1 to the degree.
  In GAP, however, the function `IsTransitive`, called with a permutation
  group, checks whether this group is transitive on the points which are
  moved by it.
  Thus the group generated by the permutation `(1, 2, 4)` is regarded as
  transitive in GAP but as intransitive in Oscar.


## Notes for Polymake users

- OSCAR (and Julia) is `1`-based, meaning that it counts from `1`, rather than
  from `0` like polymake. For most properties we have taken care of the
  translation but be aware that it might pop up at some point and generate
  confusion.

  For convenience, `Polymake.jl` provides `Polymake.to_one_based_indexing` and
  `Polymake.to_zero_based_indexing`.

- Polyhedra and polyhedral complexes in OSCAR are represented inhomogeneously,
  i.e. without the leading `1` for vertices or `0` for rays. Hence constructors
  take points, rays, and lineality generators separately.

- `user_method`s cannot be accessed via Julia's dot syntax, i.e. something like

  ```julia
  c = Polymake.polytope.cube(3)
  c.AMBIENT_DIM
  ```

  will not work. Instead `user_method`s are attached as Julia functions in
  their respective application. They are always written in lowercase. In the
  example the following works:

  ```julia
  c = Polymake.polytope.cube(3)
  Polymake.polytope.ambient_dim(c)
  ```
