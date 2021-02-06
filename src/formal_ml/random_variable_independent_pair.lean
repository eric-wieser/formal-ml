/-
Copyright 2021 Google LLC

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
import measure_theory.measurable_space

import measure_theory.measure_space
import measure_theory.outer_measure
import measure_theory.lebesgue_measure
import measure_theory.integration

import measure_theory.borel_space
import data.set.countable
import formal_ml.nnreal
import formal_ml.sum
import formal_ml.lattice
import formal_ml.measurable_space
import formal_ml.classical
import data.equiv.list
import formal_ml.prod_measure
import formal_ml.finite_pi_measure
import formal_ml.probability_space
import formal_ml.monotone_class
import formal_ml.independent_events

/-!
  This file focuses on more esoteric proofs that random variables are identical.
  In particular, given two random variables X Y with a common measurable space as a codomain,
  where the codomain is generated by some set of measurable sets S.
  X and Y are identical if they are identical on measurable sets in S, assuming S
  has some particular properties. The first is that S is an algebra, i.e. S has the 
  universal set and is closed under set difference.

  An alternative is that S is (basically) a semi-algebra, i.e. it has the empty set 
  and is closed under intersection, and semi-closed under complement. Normally, a 
  semi-algebra would require the universal set, but that is not required for this
  purpose.

  This is most useful for proving independent and identical random variables, when
  considered as an aggregate random variable, are identical.

  The core is the monotone class theorem, measurable_space.generate_from_monotone_class,
  defined in formal_ml.monotone_class.
-/



lemma independent_event_pair_forall 
  {Ω:Type*} {P:probability_space Ω} {A:event P} {f : ℕ → event P}:
                           (∀ (i:ℕ), (f i.succ).val ⊆ (f i).val) →  
   (∀ (i:ℕ), independent_event_pair A (f i)) →
   (independent_event_pair A (∀ᵣ i, f i)) := begin
  intros h1 h2,
  unfold independent_event_pair,
  rw Pr_forall_eq_infi h1,
  have h3:(A∧∀ᵣ (i : ℕ), f i) = (∀ᵣ (i : ℕ), A ∧ f i),
  { apply event.eq, simp, ext ω, split; intros h3_1; simp at h3_1; simp [h3_1],
    apply (h3_1 0).left },
  rw h3,
  rw Pr_forall_eq_infi,
  rw nnreal.mul_infi,
  unfold independent_event_pair at h2,
  have h4:(λ i, Pr[A ∧ (f i)]) = (λ i, Pr[A] * Pr[f i]),
  { ext i, rw h2 i },
  rw h4,
  intros i,
  simp,
  apply set.subset.trans,
  apply set.inter_subset_right,
  apply h1,
end


lemma independent_event_pair_exists_monotone 
  {Ω:Type*} {P:probability_space Ω} {A:event P} {f : ℕ → event P}:
                           monotone (λ (i:ℕ), (f i).val) →  
   (∀ (i:ℕ), independent_event_pair A (f i)) →
   (independent_event_pair A (∃ᵣ i, f i)) := begin
  intros h1 h2,
  unfold independent_event_pair,
  rw Pr_exists_eq_supr h1,
  have h3:(A∧∃ᵣ (i : ℕ), f i) = (∃ᵣ (i : ℕ), A ∧ f i),
  { apply event.eq, simp, ext ω, split; intros h3_1, 
    { simp at h3_1, simp [h3_1] },
    { simp at h3_1, simp [h3_1] }, },
  rw h3,
  rw Pr_exists_eq_supr,
  rw nnreal.mul_supr,
  unfold independent_event_pair at h2,
  have h4:(λ i, Pr[A ∧ (f i)]) = (λ i, Pr[A] * Pr[f i]),
  { ext i, rw h2 i },
  rw h4,
  { simp [bdd_above], rw set.nonempty_def,
    apply exists.intro (1:nnreal),
    rw mem_upper_bounds,
    intros x h_mem,
    simp at h_mem,
    cases h_mem with i h_mem,
    subst x,
    apply Pr_le_one },
  { intros i j h_le, simp,
    apply set.subset.trans,
    apply set.inter_subset_right,
    apply h1, apply h_le },
end

lemma random_variable_independent_pair_on_algebra {Ω α₁ α₂:Type*} (s₁: set (set α₁)) (s₂:set (set α₂))
  (A₁:s₁.is_algebra) (A₂:s₂.is_algebra)
  {P:probability_space Ω}
  {X₁:P →ᵣ (measurable_space.generate_from s₁)}
  {X₂:P →ᵣ (measurable_space.generate_from s₂)}:
  (∀ (T₁:measurable_setB (measurable_space.generate_from s₁))
     (T₂:measurable_setB (measurable_space.generate_from s₂)),
     T₁.val ∈ s₁ → T₂.val ∈ s₂ 
     → independent_event_pair (X₁ ∈ᵣ T₁) (X₂ ∈ᵣ T₂)) → 
  random_variable_independent_pair X₁ X₂ := begin
  intros h1 U₁,
  cases U₁,
  have AM₁ := A₁.monotone_class,
  have AM₂ := A₂.monotone_class,

  have h_meas₁:∀ {T':set α₁}, s₁.monotone_class T' →
          (measurable_space.generate_from s₁).measurable_set' T',
  { intros T' h_1, 
    rw measurable_space.generate_from_monotone_class at h_1,
    simp [measurable_space.generate_from],
    apply h_1, apply A₁ },
  have h_meas₂:∀ {T':set α₂}, s₂.monotone_class T' →
          (measurable_space.generate_from s₂).measurable_set' T',
  { intros T' h_1, 
    rw measurable_space.generate_from_monotone_class at h_1,
    simp [measurable_space.generate_from],
    apply h_1, apply A₂ },
  have h_mono_1:s₁.monotone_class U₁_val,
  { rw measurable_space.generate_from_monotone_class,
    simp [measurable_space.generate_from] at U₁_property,
    apply U₁_property, apply A₁ },
  induction h_mono_1 with U₁' h_U₁' f₁ h_rec₁ h_mono₁ h_ind₁ f₁ h_rec₁ h_mono₁ h_ind₁,
  -- The base case for U₁, solved by induction on U₂.
  intros U₂, cases U₂, 
  have h_mono_2:s₂.monotone_class U₂_val,
  { rw measurable_space.generate_from_monotone_class,
    simp [measurable_space.generate_from] at U₂_property,
    apply U₂_property, apply A₂ },
  induction h_mono_2 with U₂' h_U₂' f₂ h_rec₂ h_mono₂ h_ind₂ f₂ h_rec₂ h_mono₂ h_ind₂,
  -- The base base case.
  { apply h1, apply h_U₁', apply h_U₂' },
  { have h_Inter:(X₂ ∈ᵣ ⟨set.Inter f₂, U₂_property⟩)
                 = (∀ᵣ i, (X₂ ∈ᵣ ⟨f₂ i, h_meas₂ (h_rec₂ i)⟩)), 
    { apply event.eq, ext1 ω, split; intros h_Inter; simp at h_Inter;
      simp [h_Inter] },
    rw h_Inter,
    apply independent_event_pair_forall,
    { intros i, have h_mono_i := h_mono₂ i,
      simp, intros ω, apply h_mono_i },
    { intros i, have h_ind_i := h_ind₂ i,
      apply h_ind_i } },
  { have h_Union: (X₂ ∈ᵣ ⟨set.Union f₂, U₂_property⟩)
                  = (∃ᵣ i, (X₂ ∈ᵣ ⟨f₂ i, h_meas₂ (h_rec₂ i)⟩)),
    { apply event.eq, ext1 ω, split; intros h_Union_1; simp at h_Union_1;
      simp [h_Union_1] },
    rw h_Union,
    apply independent_event_pair_exists_monotone,
    { intros i j h_le, have h_mono_i := h_mono₂ h_le,
      simp, intros ω, apply h_mono_i },
    { intros i, have h_ind_i := h_ind₂ i,
      apply h_ind_i } },
  -- The base case of T₁ is resolved. Now we continue...     
  { intros T₁, apply independent_event_pair.symm,
    have h_Inter:(X₁ ∈ᵣ ⟨set.Inter f₁, U₁_property⟩)
                 = (∀ᵣ i, (X₁ ∈ᵣ ⟨f₁ i, h_meas₁ (h_rec₁ i)⟩)), 
    { apply event.eq, ext1 ω, split; intros h_Inter; simp at h_Inter;
      simp [h_Inter] },
    rw h_Inter,
    apply independent_event_pair_forall,
    { intros i, have h_mono_i := h_mono₁ i,
      simp, intros ω, apply h_mono_i },
    { intros i, apply independent_event_pair.symm,
      have h_ind_i := h_ind₁ i,
      apply h_ind_i } },  
  { intros T₁, apply independent_event_pair.symm,
    have h_Union: (X₁ ∈ᵣ ⟨set.Union f₁, U₁_property⟩)
                  = (∃ᵣ i, (X₁ ∈ᵣ ⟨f₁ i, h_meas₁ (h_rec₁ i)⟩)),
    { apply event.eq, ext1 ω, split; intros h_Union_1; simp at h_Union_1;
      simp [h_Union_1] },
    rw h_Union,
    apply independent_event_pair_exists_monotone,
    { intros i j h_le, have h_mono_i := h_mono₁ h_le,
      simp, intros ω, apply h_mono_i },
    { intros i, apply independent_event_pair.symm,
      have h_ind_i := h_ind₁ i,
      apply h_ind_i } },     
end


/- This allows for the measurable space to be generated from a different
   set. -/
lemma random_variable_independent_pair_on_algebra' {Ω α₁ α₂:Type*} (s₁: set (set α₁)) (s₂:set (set α₂))
  (A₁:s₁.is_algebra) (A₂:s₂.is_algebra)
  (M₁:measurable_space α₁)
  (M₂:measurable_space α₂)
  {P:probability_space Ω}
  {X₁:P →ᵣ M₁}
  {X₂:P →ᵣ M₂}:
  (M₁ = measurable_space.generate_from s₁) →
  (M₂ = measurable_space.generate_from s₂) →
  (∀ (T₁:measurable_setB M₁)
     (T₂:measurable_setB M₂),
     T₁.val ∈ s₁ → T₂.val ∈ s₂ 
     → independent_event_pair (X₁ ∈ᵣ T₁) (X₂ ∈ᵣ T₂)) → 
  random_variable_independent_pair X₁ X₂ := begin
  intros h1 h2 h3 T₁ T₂,
  tactic.unfreeze_local_instances,
  subst M₁,
  subst M₂,
  apply random_variable_independent_pair_on_algebra,
  apply A₁,
  apply A₂,
  apply h3,
end

lemma measurable_space.generate_from_disjoint_union_closure {α:Type*}
  {s:set (set α)}:
  measurable_space.generate_from s = measurable_space.generate_from s.disjoint_union_closure :=
begin
  apply le_antisymm,
  { apply measurable_space.generate_from_le,
    intros t h_t, simp [measurable_space.generate_from],
    apply measurable_space.generate_measurable.basic,
    apply set.disjoint_union_closure_self,
    apply h_t },
  { apply measurable_space.generate_from_le,
    intros t h_t, rw set.mem_disjoint_union_closure_iff at h_t,
    cases h_t with m h_t,
    cases h_t with f h_t,
    cases h_t with h_in_s h_t,
    cases h_t with h_pairwise h_f_def,
    subst t,
    haveI E:encodable (fin m) := fintype.encodable (fin m),
    apply measurable_set.Union, intros b, 
    apply measurable_space.measurable_set_generate_from, apply h_in_s },
end

lemma random_variable_independent_pair_on_semialgebra {Ω α₁ α₂:Type*} (s₁: set (set α₁)) 
  (s₂:set (set α₂))
  (A₁:s₁.is_semialgebra) (A₂:s₂.is_semialgebra)
  {P:probability_space Ω}
  {X₁:P →ᵣ (measurable_space.generate_from s₁)}
  {X₂:P →ᵣ (measurable_space.generate_from s₂)}:
  (∀ (T₁:measurable_setB (measurable_space.generate_from s₁))
     (T₂:measurable_setB (measurable_space.generate_from s₂)),
     T₁.val ∈ s₁ → T₂.val ∈ s₂ 
     → independent_event_pair (X₁ ∈ᵣ T₁) (X₂ ∈ᵣ T₂)) → 
  random_variable_independent_pair X₁ X₂ := begin
  intros h1,
  have CA₁ := A₁.disjoint_union_closure,
  have CA₂ := A₂.disjoint_union_closure,
  apply random_variable_independent_pair_on_algebra' (s₁.disjoint_union_closure)
    (s₂.disjoint_union_closure) (A₁.disjoint_union_closure) (A₂.disjoint_union_closure),
  apply measurable_space.generate_from_disjoint_union_closure,
  apply measurable_space.generate_from_disjoint_union_closure,
  intros T₁ T₂ h_T₁ h_T₂,
  rw set.mem_disjoint_union_closure_iff at h_T₁,
  cases h_T₁ with m₁ h_T₁,
  cases h_T₁ with f₁ h_T₁,
  cases h_T₁ with h_f₁_in_s h_T₁,
  cases h_T₁ with h_pairwise₁ h_def₁,
  rw set.mem_disjoint_union_closure_iff at h_T₂,
  cases h_T₂ with m₂ h_T₂,
  cases h_T₂ with f₂ h_T₂,
  cases h_T₂ with h_f₂_in_s h_T₂,
  cases h_T₂ with h_pairwise₂ h_def₂,
  cases T₁,
  cases T₂,
  simp at h_def₁,
  simp at h_def₂,
  subst T₁_val,
  subst T₂_val,
  have h_meas₁:∀ (i:fin m₁), (measurable_space.generate_from s₁).measurable_set' (f₁ i),
  { intros i, apply measurable_space.measurable_set_generate_from, apply h_f₁_in_s },
  have h_meas₂:∀ (i:fin m₂), (measurable_space.generate_from s₂).measurable_set' (f₂ i),
  { intros i, apply measurable_space.measurable_set_generate_from, apply h_f₂_in_s },
  have h_union1: (X₁ ∈ᵣ ⟨set.Union f₁, T₁_property⟩) = (∃ᵣ i, X₁ ∈ᵣ ⟨f₁ i, h_meas₁ i⟩),
  { apply event.eq, ext ω, split; intros h_union1_1; simp at h_union1_1; simp [h_union1_1] },
  have h_union2: (X₂ ∈ᵣ ⟨set.Union f₂, T₂_property⟩) = (∃ᵣ i, X₂ ∈ᵣ ⟨f₂ i, h_meas₂ i⟩),
  { apply event.eq, ext ω, split; intros h_union2_1; simp at h_union2_1; simp [h_union2_1] },
  rw h_union1,
  rw h_union2,
  classical,
  apply independent_event_pair_exists,
  intros i h_i,
  apply independent_event_pair.symm,
  apply independent_event_pair_exists,
  intros j h_j,
  apply independent_event_pair.symm,
  apply h1,
  { simp, apply h_f₁_in_s },
  { simp, apply h_f₂_in_s },
  { intros i h_i_in_univ j h_j_in_univ h_ne, simp [function.on_fun],
    have h_pairwise_ij := h_pairwise₁ i j h_ne,
    simp [function.on_fun] at h_pairwise_ij, rw disjoint_iff, rw disjoint_iff at h_pairwise_ij,
    simp at h_pairwise_ij, simp [h_pairwise_ij], rw ← set.subset_empty_iff, rw set.subset_def,
    intros ω h_ω, simp at h_ω, rw ← set.subset_empty_iff at h_pairwise_ij, rw set.subset_def
    at h_pairwise_ij, have h_X := h_pairwise_ij (X₁.val ω), simp at h_X, exfalso, apply h_X,
    simp [h_ω], simp [h_ω] },
  { intros i h_i_univ j h_j_univ h_ne, simp [function.on_fun],
    have h_pairwise_ij := h_pairwise₂ i j h_ne,
    simp [function.on_fun] at h_pairwise_ij, rw disjoint_iff, rw disjoint_iff at h_pairwise_ij,
    simp at h_pairwise_ij, simp [h_pairwise_ij], rw ← set.subset_empty_iff, rw set.subset_def,
    intros ω h_ω, simp at h_ω, rw ← set.subset_empty_iff at h_pairwise_ij, rw set.subset_def
    at h_pairwise_ij, have h_X := h_pairwise_ij (X₂.val ω), simp at h_X, exfalso, apply h_X,
    simp [h_ω], simp [h_ω] },
end


lemma random_variable_independent_pair_on_semialgebra' {Ω α₁ α₂:Type*} (s₁: set (set α₁)) 
  (s₂:set (set α₂))
  (A₁:s₁.is_semialgebra) (A₂:s₂.is_semialgebra)
  (M₁:measurable_space α₁)
  (M₂:measurable_space α₂)
  {P:probability_space Ω}
  {X₁:P →ᵣ M₁}
  {X₂:P →ᵣ M₂}:
  (M₁ = measurable_space.generate_from s₁) →
  (M₂ = measurable_space.generate_from s₂) →
  (∀ (T₁:measurable_setB M₁)
     (T₂:measurable_setB M₂),
     T₁.val ∈ s₁ → T₂.val ∈ s₂ 
     → independent_event_pair (X₁ ∈ᵣ T₁) (X₂ ∈ᵣ T₂)) → 
  random_variable_independent_pair X₁ X₂ := begin
  intros h1 h2 h3 T₁ T₂,
  tactic.unfreeze_local_instances,
  subst M₁,
  subst M₂,
  apply random_variable_independent_pair_on_semialgebra,
  apply A₁,
  apply A₂,
  apply h3,
end
