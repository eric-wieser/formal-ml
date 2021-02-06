/-
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 -/
import analysis.calculus.mean_value
import data.complex.exponential

import formal_ml.convex_optimization
--import formal_ml.analytic_function
import analysis.special_functions.exp_log
import formal_ml.nnreal

/-
  Note: after I proved this, I found that it already was in mathlib.
-/

--TODO: lift this until it doesn't depend upon has_derivative
lemma has_derivative_exp:has_derivative real.exp real.exp :=
begin
  unfold has_derivative,
  intro x,
  apply real.has_deriv_at_exp,
end


lemma exp_bound3 (x:real):0 ≤ real.exp x - (x + 1) :=
begin
  let f:=λ x,real.exp x - (x + 1),
  let f':=λ x,real.exp x - 1,
  let f'':=λ x,real.exp x,
  begin
    have f_def:f=λ x,real.exp x - (x + 1),
    {
      refl,
    },
    have f_def':f'=λ x,real.exp x - 1,
    {
      refl,
    },
    have f_def'':f''=λ x,real.exp x,
    {
      refl,
    },
    have A1:has_derivative f f',
    {
      rw f_def,
      rw f_def',
      apply has_derivative_sub real.exp real.exp  (λ x, (x + 1)) (1),
      {
        apply has_derivative_exp,
      },
      {
        apply has_derivative_add_const,
        apply has_derivative_id,
      },
    },
    have A2:has_derivative f' f'',
    {
      apply has_derivative_add_const,
      apply has_derivative_exp,
    },
    have A3:∀ y, f 0 ≤ f y,
    {
      intro y,
      apply is_minimum,
      {
        apply A1,
      },
      {
        apply A2,
      },
      {
        intro z,
        rw f_def'',
        apply le_of_lt,
        apply real.exp_pos,
      },
      have A3D:f' 0 = real.exp 0 - 1,
      {
        refl,
      },
      rw A3D,
      simp,
    },
    have A4:f 0 = 0,
    {
      rw f_def,
      simp,
    },
    rw A4 at A3,
    have A5:f x = real.exp x - (x + 1),
    {
      refl,
    },
    rw ← A5,
    apply A3,
  end
end


lemma exp_bound2 (x:real):1 - x ≤ real.exp(-x) :=
begin
  have A1:0 ≤ real.exp(-x) - ((-x) + 1),
  {
    apply exp_bound3,
  },
  have A2:((-x) + 1) ≤ real.exp(-x) := le_of_sub_nonneg A1,
  rw add_comm at A2,
  rw sub_eq_add_neg,
  exact A2,
end


--TODO: verify this is exactly what we need first.
lemma nnreal_exp_bound (x:nnreal):(1-x) ≤ nnreal.exp(-x) :=
begin
  apply nnreal.coe_le_coe.mp,
  rw nnreal_exp_eq,
  have A1:((x:real) ≤ 1) ∨ (1 ≤ (x:real)),
  {
    apply linear_order.le_total,
  },
  cases A1,
  {
    rw nnreal.coe_sub,
    apply exp_bound2 (↑x),
    apply A1,
  },
  {
    rw nnreal.sub_eq_zero,
    {
      apply le_of_lt,
      apply real.exp_pos,
    },
    {
      apply A1,
    }
  }
end

--This exact theorem is used for PAC bounds.
lemma nnreal_exp_bound2 (x:nnreal) (k:ℕ):(1 - x)^k ≤ nnreal.exp(-x * k) :=
begin
  have A1:(1-x) ≤ nnreal.exp(-x),
  {
    apply nnreal_exp_bound,
  },
  have A2:(1 - x)^k ≤ (nnreal.exp(-x))^k,
  {
    apply nnreal_pow_mono,
    exact A1,
  },
  have A3:nnreal.exp(-x)^k=nnreal.exp(-x * k),
  {
    symmetry,
    rw mul_comm,
    apply nnreal_exp_pow,
  },
  rw ← A3,
  apply A2,
end

