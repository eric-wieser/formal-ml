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
import measure_theory.measurable_space

import measure_theory.measure_space
import formal_ml.set
import formal_ml.finset
import formal_ml.classical

lemma set_Prop_le_def {α:Type*}
  (M M2:set α → Prop):
  M ≤ M2 ↔
  (∀ X:set α, M X → M2 X)
   :=
begin
  refl,
end

lemma finset_union_measurable {α:Type*} {T:finset α} {β:Type*} [measurable_space β] {U:α → set β}:
  (∀ t∈ T, measurable_set (U t)) →
  measurable_set (⋃ x ∈ T, U x) :=
begin
  intros a,
  have A1:(set.sUnion (set.image U ({a|a∈ T}:set α))) = (⋃ x ∈ T, U x),
  {
    simp,
  },
  rw ← A1,
  apply measurable_set.sUnion,
  {
    apply set.countable.image,
    apply set.finite.countable,
    apply finite_finset,
  },
  {
    intros,
    simp at H,
    cases H with x H,
    cases H with A2 A3,
    subst t,
    apply a,
    exact A2,
  }
end

lemma finset_inter_measurable {α:Type*} {T:finset α} {β:Type*} [measurable_space β] {U:α → set β}:
  (∀ t∈ T, measurable_set (U t)) →
  measurable_set (⋂ x ∈ T, U x) :=
begin
  intros a,
  have A1:(set.sInter (set.image U ({a|a∈ T}:set α))) = (⋂ x ∈ T, U x),
  {
    simp,
  },
  rw ← A1,
  apply measurable_set.sInter,
  {
    apply set.countable.image,
    apply set.finite.countable,
    apply finite_finset,
  },
  {
    intros,
    simp at H,
    cases H with x H,
    cases H with A2 A3,
    subst t,
    apply a,
    exact A2,
  }
end

lemma measurable_space_le_def {α:Type*}
  (M:measurable_space α) (M2:measurable_space α):
  M.measurable_set' ≤  M2.measurable_set'
  ↔  M ≤ M2 :=
begin
  refl,
end

lemma measurable_space_le_def2 {α:Type*}
  (M:measurable_space α) (M2:measurable_space α):
  (∀ X:set α, M.measurable_set' X → M2.measurable_set' X) ↔
   M ≤ M2 :=
begin
  intros,
  apply iff.trans,
  {
    apply set_Prop_le_def,
  },
  {
    apply measurable_space_le_def,
  }
end

-- Delete?
lemma measurable_space_le_intro {α:Type*}
  (M:measurable_space α) (M2:measurable_space α):
  (∀ X:set α, M.measurable_set' X → M2.measurable_set' X) →
   M ≤ M2 :=
begin
  intros a,
  have A1:M.measurable_set' ≤  M2.measurable_set'
  ↔  M ≤ M2,
  {
    apply measurable_space_le_def,
  },
  apply A1.mp,
  have A2:M.measurable_set' ≤ M2.measurable_set' ↔
  (∀ X:set α, M.measurable_set' X → M2.measurable_set' X),
  {
    apply set_Prop_le_def,
  },
  apply A2.mpr,
  apply a,
end



lemma measurable_def {α β:Type*}
  [M1:measurable_space α] [M2:measurable_space β] (f:α → β):
  (∀ B:(set β), (measurable_set B) → measurable_set (f ⁻¹' B))
  ↔ (measurable f) :=
begin
  unfold measurable,
end

lemma measurable_intro {α β:Type*}
  [measurable_space α] [measurable_space β] (f:α → β):
  (∀ B:(set β), measurable_set B → measurable_set (f ⁻¹' B))
  → (measurable f) :=
begin
  apply (measurable_def _).mp,
end

lemma measurable_elim {α β:Type*}
  [measurable_space α] [measurable_space β] (f:α → β) (B:set β):
  (measurable f)→ (measurable_set B) → (measurable_set (f ⁻¹' B)) :=
begin
  intros a a_1,
  apply (measurable_def _).mpr,
  apply a,
  apply a_1,
end


lemma measurable_fun_product_measurableh {α β:Type*}
  [M1:measurable_space α] [M2:measurable_space β]:
  (@prod.measurable_space α β M1 M2) = M1.comap prod.fst ⊔ M2.comap prod.snd :=
begin
  refl
end


lemma comap_elim {α β:Type*} [M2:measurable_space β] (f:α → β) (B:set β):
  (measurable_set B) →
  (M2.comap f).measurable_set'  (set.preimage f B) :=
begin
  intros a,
  unfold measurable_space.comap,
  simp,
  apply exists.intro B,
  split,
  apply a,
  refl
end


lemma measurable_comap {α β:Type*} [M1:measurable_space α] [M2:measurable_space β] (f:α → β):
  (M2.comap f) ≤ M1 → measurable f :=
begin
  intros a,
  apply measurable_intro,
  intros B a_1,
  have A1:(M2.comap f).measurable_set'  (set.preimage f B),
  {
    apply comap_elim,
    apply a_1,
  },
  rw ← measurable_space_le_def2 at a,
  apply a,
  apply A1,
end

lemma fst_measurable {α β:Type*}
  [M1:measurable_space α] [M2:measurable_space β]:measurable (λ x:(α × β), x.fst) :=
begin
  apply measurable_comap,
  have A1:M1.comap prod.fst ≤ (@prod.measurable_space α β M1 M2),
  {
    rw measurable_fun_product_measurableh,
    apply complete_lattice.le_sup_left (M1.comap prod.fst) (M2.comap prod.snd),
  },
  apply A1,
end

lemma snd_measurable {α β:Type*}
  [M1:measurable_space α] [M2:measurable_space β]:measurable (λ x:(α × β), x.snd) :=
begin
  apply measurable_comap,
  have A1:M2.comap prod.snd ≤ (@prod.measurable_space α β M1 M2),
  {
    rw measurable_fun_product_measurableh,
    apply complete_lattice.le_sup_right (M1.comap prod.fst) (M2.comap prod.snd),
  },
  apply A1,
end


lemma comap_def {α β:Type*} {B:set (set β)}
  (f:α → β):
  @measurable_space.comap α β f (measurable_space.generate_from B)
  = (measurable_space.generate_from (set.image (set.preimage f) B)) :=
begin
  apply measurable_space.comap_generate_from,
end

lemma comap_fst_def {α β:Type*} {Bα:set (set α)}:
  (measurable_space.generate_from Bα).comap (@prod.fst α β) =
  measurable_space.generate_from {U:set (α × β)|∃ A∈ Bα, U = set.prod A set.univ} :=
begin
  rw measurable_space.comap_generate_from,
  rw set.preimage_fst_def,
end

lemma comap_snd_def {α β:Type*} {Bβ:set (set β)}:
  (measurable_space.generate_from Bβ).comap (@prod.snd α β) =
  measurable_space.generate_from {U:set (α × β)|∃ B∈ Bβ, U = set.prod set.univ B} :=
begin
  rw measurable_space.comap_generate_from,
  rw set.preimage_snd_def,
end



lemma measurable_space_sup_def {α:Type*} {B C:set (set α)}:
  (measurable_space.generate_from B) ⊔ (measurable_space.generate_from C) =
  (measurable_space.generate_from (B ∪ C)) :=
begin
  apply measurable_space.generate_from_sup_generate_from,
end

lemma prod_measurable_space_def {α β:Type*} {Bα:set (set α)}
  {Bβ:set (set β)}:
  (@prod.measurable_space α β (measurable_space.generate_from Bα)
  (measurable_space.generate_from Bβ)) =
  @measurable_space.generate_from (α × β) (
    {U:set (α × β)|∃ A∈ Bα, U = set.prod A set.univ} ∪
    {U:set (α × β)|∃ B∈ Bβ, U = set.prod set.univ B})
   :=
begin
  rw measurable_fun_product_measurableh,
  rw comap_fst_def,
  rw comap_snd_def,
  rw measurable_space_sup_def,
end


lemma set.sUnion_eq_univ_elim {α:Type*} {S:set (set α)} (a:α):
  (set.sUnion S = set.univ) → (∃ T∈S, a∈ T) :=
begin
  intro A1,
  have A2:a∈ set.univ := set.mem_univ a,
  rw ← A1 at A2,
  simp at A2,
  cases A2 with T A2,
  apply exists.intro T,
  apply exists.intro A2.left,
  apply A2.right,
end

lemma prod_measurable_space_le {α β:Type*} {Bα:set (set α)}
  {Bβ:set (set β)}:
  @measurable_space.generate_from (α × β) 
    {U:set (α × β)|∃ A∈ Bα, ∃ B∈Bβ,  U = set.prod A B} ≤
  (@prod.measurable_space α β (measurable_space.generate_from Bα)
  (measurable_space.generate_from Bβ))
   :=
begin
  rw prod_measurable_space_def,
  apply measurable_space.generate_from_le, intros X A5,
  simp at A5,
  cases A5 with A A5,
  cases A5 with A5 A6,
  cases A6 with B A6,
  cases A6 with A6 A7,
  have A8:(set.prod A (@set.univ β)) ∩ 
          (set.prod (@set.univ α) B) = set.prod A B,
  {
    ext p,split;intros A3A;{
      simp at A3A,
      simp,
       --cases p,
      apply A3A,
    },
  },
  rw ← A8 at A7,
  rw A7,
  apply measurable_set.inter,
  {
    apply measurable_space.measurable_set_generate_from,
    apply set.mem_union_left,
    simp,
    apply exists.intro A,
    split,
    apply A5,
    refl,
  },
  { 
    apply measurable_space.measurable_set_generate_from,
    apply set.mem_union_right,
    simp,
    apply exists.intro B,
    split,
    apply A6,
    refl,
  },
end

lemma prod_measurable_space_def2 {α β:Type*} {Bα:set (set α)}
  {Bβ:set (set β)} {Cα:set (set α)} {Cβ:set (set β)}:
  (set.countable Cα) →
  (set.countable Cβ) →
  (Cα ⊆ Bα) →
  (Cβ ⊆ Bβ) →
  (set.sUnion Cα = set.univ) →
  (set.sUnion Cβ = set.univ) →
  (@prod.measurable_space α β (measurable_space.generate_from Bα)
  (measurable_space.generate_from Bβ)) =
  @measurable_space.generate_from (α × β) 
    {U:set (α × β)|∃ A∈ Bα, ∃ B∈Bβ,  U = set.prod A B}
   :=
begin
  intros A1 A2 A3 A4 AX1 AX2,
  --rw prod_measurable_space_def,
  apply le_antisymm,
  {
    rw prod_measurable_space_def,
    apply measurable_space.generate_from_le,
    intros X A5,
    simp at A5,
    cases A5,
    {
       cases A5 with A A5,
       cases A5 with A5 A6,
       have A7:X = set.sUnion (set.image (set.prod A) Cβ), 
       {
         rw A6,
         ext a,split;intro A7A;simp;simp at A7A,
         {
           have A7B := set.sUnion_eq_univ_elim a.snd AX2,
           cases A7B with i A7B,
           cases A7B with A7B A7C,
           apply exists.intro i,
           apply and.intro A7B (and.intro A7A A7C),
         },
         {
           cases A7A with i A7A,
           apply A7A.right.left,
         },
       },
       rw A7,
       --apply measurable_space.measurable_set_generate_from,
       apply measurable_set.sUnion,
       apply set.countable.image,
       apply A2,
       intro U,
       intro A8,
       simp at A8,
       cases A8 with B A8,
       cases A8 with A8 A9,
       subst U,
       apply measurable_space.measurable_set_generate_from,
       simp,
       apply exists.intro A,
       split,
       apply A5,
       apply exists.intro B,
       split,
       rw set.subset_def at A4,
       apply A4,
       apply A8,
       refl,
    },
    {
       cases A5 with B A5,
       cases A5 with A5 A6,
       have A7:X = set.sUnion (set.image (λ x, set.prod x B)  Cα), 
       {
         rw A6,
         ext a,split;intro A7A;simp;simp at A7A,
         {
           have A7B := set.sUnion_eq_univ_elim a.fst AX1,
           cases A7B with i A7B,
           cases A7B with A7B A7C,
           apply exists.intro i,
           apply and.intro A7B (and.intro A7C A7A),
         },
         {
           cases A7A with i A7A,
           apply A7A.right.right,
         },
       },
       rw A7,
       --apply measurable_space.measurable_set_generate_from,
       apply measurable_set.sUnion,
       apply set.countable.image,
       apply A1,
       intro U,
       intro A8,
       simp at A8,
       cases A8 with A A8,
       cases A8 with A8 A9,
       subst U,
       apply measurable_space.measurable_set_generate_from,
       simp,
       apply exists.intro A,
       split,
       rw set.subset_def at A3,
       apply A3,
       apply A8,
       apply exists.intro B,
       split,
       apply A5,
       refl,
    },
  },
  {
    apply prod_measurable_space_le,
  }
end


lemma preimage_compl {α β:Type*} (f:α → β) (S:set β):
  (f ⁻¹' Sᶜ) = ((f ⁻¹' S)ᶜ) :=
begin
  ext,
  split;intros a,
  {
    intro a_1,
    unfold set.preimage at a,
    simp at a,
    apply a,
    apply a_1,
  },
  {
    unfold set.preimage,
    simp,
    intro a_1,
    apply a,
    apply a_1,
  }
end


lemma preimage_Union {α β:Type*} (f:α → β) (g:ℕ → set β):
   (f ⁻¹' ⋃ (i : ℕ), g i)=(⋃ (i : ℕ), f ⁻¹' (g i)) :=
begin
  ext,
  split;intros a,
  {
    cases a with B a,
    cases a with H a,
    cases H with y H,
    split,
    simp,
    split,
    apply exists.intro y,
    {
      simp at H,
    },
    {
      simp at H,
      subst B,
      apply a,
    }
  },
  {
    cases a with A a,
    cases a with A1 A2,
    cases A1 with i A3,
    simp at A3,
    subst A,
    split,
    simp,
    split,
    {
      apply exists.intro i,
      refl,
    },
    {
      apply A2,
    },
  }
end



lemma generate_from_measurable {α β:Type*} [M:measurable_space α] [M2:measurable_space β]
   (X:set (set β)) (f:α → β):
   (measurable_space.generate_from X = M2)→
   (∀ B∈ X, measurable_set (set.preimage f B))→
   (measurable f) :=
begin
  intros a a_1,
  apply measurable_intro,
  intros B a_2,
  have A1:@measurable_set β (measurable_space.generate_from X) B,
  {
    rw a,
    apply a_2,
  },
  clear a_2, -- Important for induction later.
  have A2:measurable_space.generate_measurable X B,
  {
    apply A1,
  },
  induction A2,
  {
    apply a_1,
    apply A2_H,
  },
  {
    simp,
  },
  { -- ⊢ measurable_set (f ⁻¹' -A2_s)
    rw preimage_compl,
    apply measurable_space.measurable_set_compl,
    apply A2_ih,
    {
      apply (measurable_set.compl_iff).mp,
      apply A1,
    },
  },
  {
    rw preimage_Union,
    apply measurable_space.measurable_set_Union,
    intros i,
    apply A2_ih,
    {
      apply A2_ᾰ,
    }
  }
end


lemma generate_from_self {α:Type*}
  (M:measurable_space α):
  M = measurable_space.generate_from {s : set α|measurable_space.measurable_set' M s} :=
begin
  ext,
  split;intros a,
  {
    apply measurable_space.generate_measurable.basic,
    apply a,
  },
  {
    induction a,
    {
      apply a_H,
    },
    {
      apply measurable_space.measurable_set_empty,
    },
    {
      apply measurable_space.measurable_set_compl,
      apply a_ih,
    },
    {
      apply measurable_space.measurable_set_Union,
      apply a_ih,
    },
  }
end


lemma measurable_fun_comap_def {α β:Type*}
  [M2:measurable_space β]  (f:α → β):
  measurable_space.comap f M2 = measurable_space.generate_from
  {s : set α|∃ (s' : set β), measurable_space.measurable_set' M2 s' ∧ f ⁻¹' s' = s} :=
begin
  unfold measurable_space.comap,
  apply generate_from_self,
end




lemma measurable_fun_product_measurable {α β γ:Type*}
  [M1:measurable_space α] [M2:measurable_space β] [M3:measurable_space γ]
  (X: α →  β) (Y: α → γ):
  measurable X →
  measurable Y →
  measurable (λ a:α, prod.mk (X a) (Y a)) :=
begin
  intros B1 B2,
  have A1:@measurable _ _ _ (@prod.measurable_space β γ M2 M3) (λ a:α, prod.mk (X a) (Y a)),
  {
    have A1A:(@prod.measurable_space β  γ  M2 M3)=measurable_space.generate_from (
      {s : set (β × γ) | ∃ (s' : set β), measurable_space.measurable_set' M2 s' ∧ prod.fst ⁻¹' s' = s} ∪
      {s : set (β  × γ) | ∃ (s' : set γ), measurable_space.measurable_set' M3 s' ∧ prod.snd ⁻¹' s' = s}),
    {
      rw measurable_fun_product_measurableh,
      rw measurable_fun_comap_def,
      rw measurable_fun_comap_def,
      rw measurable_space.generate_from_sup_generate_from,
    },
    rw A1A,
    apply generate_from_measurable,
    {
      refl,
    },
    {
      intro BC,
      intros H,
      cases H,
      {
        cases H with B H,
        cases H,
        subst BC,
        have A1B:(λ (a : α), (X a, Y a)) ⁻¹' (prod.fst ⁻¹' B) = (X ⁻¹' B),
        {
          ext,split;intros a,
          {
            simp at a,
            apply a,
          },
          {
            simp,
            apply a,
          }
        },
        rw A1B,
        apply B1,
        apply H_left,
      },
      {
        cases H with C H,
        cases H,
        subst BC,
        have A1C:(λ (a : α), (X a, Y a)) ⁻¹' (prod.snd ⁻¹' C) = (Y ⁻¹' C),
        {
          ext,split;intros a,
          {
            simp at a,
            apply a,
          },
          {
            simp,
            apply a,
          }
        },
        rw A1C,
        apply B2,
        apply H_left,
      }
    }
  },
  apply A1,
end

lemma compose_measurable_fun_measurable {α β γ:Type*}
  [measurable_space α] [measurable_space β] [measurable_space γ]
  (X:β → γ) (Y: α→  β):
  measurable X →
  measurable Y →
  measurable (X ∘ Y) :=
begin
  intros B1 B2,
  apply measurable_intro,
  intros B a,
  have A1:(X ∘ Y ⁻¹' B)=(Y ⁻¹' (X ⁻¹' B)),
  {
    refl,
  },
  rw A1,
  apply measurable_elim Y _ B2,
  apply measurable_elim X _ B1,
  apply a
end

-- Constant functions are measurable.
-- Different than measurable_set.const
lemma const_measurable {Ω:Type*} [measurable_space Ω] {β:Type*} [measurable_space β] (c:β):
  (measurable (λ ω:Ω, c)) :=
begin
  apply measurable_const,
end

lemma measurable_set_of_le_of_measurable_set
{α : Type*} {M1 : measurable_space α} {M2 : measurable_space α} 
  {X:set α}:
  M1 ≤ M2 →
measurable_space.measurable_set' M1 X →
   measurable_space.measurable_set' M2 X :=
begin
  intros A2 A1,
  rw ← measurable_space_le_def2 at A2,
  apply A2,
  apply A1,
end

-- cf. measurable_set_prod
lemma measurable_set_prod' {β : Type*} {γ : Type*}
  {Mβ : measurable_space β} {Mγ : measurable_space γ} 
  {X:set β} {Y:set γ}:measurable_set X →
   measurable_set Y →
   measurable_set (set.prod X Y) :=
begin
  --apply measurable_set_of_le_of_measurable_set,
  intros A1 A2,
  rw generate_from_self Mβ,
  rw generate_from_self Mγ,
  apply measurable_set_of_le_of_measurable_set,
  apply prod_measurable_space_le,
  apply measurable_space.measurable_set_generate_from,
  simp,
  apply exists.intro X,
  split,
  apply A1,
  apply exists.intro Y,
  split,
  apply A2,
  refl,
end

lemma measurable.preimage {α β:Type*} [measurable_space α] [measurable_space β] {f:α → β}
   {S:set β}:measurable f → measurable_set S → measurable_set (set.preimage f S) :=
begin
  intros A1 A2,
  apply A1,
  apply A2,
end

lemma measurable.if {α β:Type*}
  {Mα:measurable_space α} {Mβ:measurable_space β}
  {E:set α} {D:decidable_pred E}
  {X Y:α → β}:measurable_set E →
  measurable X →
  measurable Y →
  measurable (λ a:α, if (E a) then (X a) else (Y a)) :=
begin
  intros A1 A2 A3,
  intros S B1,
  rw preimage_if,
  apply measurable_set.union,
  {
    apply measurable_set.inter,
    apply A1,
    apply A2,
    apply B1,
  }, 
  {
    apply measurable_set.inter,
    apply measurable_set.compl,
    apply A1,
    apply A3,
    apply B1,
  },
end 


lemma measurable_set.pi' {α:Type*} [F:fintype α] {β:α → Type*} [M:∀ a, measurable_space (β a)]
  {P:Π a, set (β a)} (T:set α):(∀ a, measurable_set (P a)) →
  measurable_set (set.pi T P) := begin
  classical,
  intros A0,
  have A1:(set.pi T P) = ⋂ (a ∈ T), ((λ (p:Π a, β a), p a) ⁻¹' (P a)),
  { ext x, simp,  },
  rw A1,
  have A3:trunc (encodable α) := encodable.trunc_encodable_of_fintype α,
  trunc_cases A3,
  haveI:encodable α := A3,
  apply measurable_set.Inter,
  intros a',
  cases classical.em (a' ∈ T) with A4 A4,
  { have A5:(⋂ (H : a' ∈ T), (λ (p : Π (a : α), β a), p a') ⁻¹' P a') =
            (λ (p : Π (a : α), β a), p a') ⁻¹' P a',
    { ext, simp; split; intros A5_1,
      apply A5_1 A4,
      intros A5_2, apply A5_1 },
      rw A5,
    have A2:measurable_space.comap (λ (p:Π a, β a), p a') (M a') ≤ measurable_space.pi,
    { simp [measurable_space.pi], apply @le_supr (measurable_space (Π a, β a)) _ _ _ (a') },
    apply A2,
    simp [measurable_space.comap],
    apply exists.intro (P a'),
    simp,
    apply A0 a' },
  { have A6:(⋂ (H : a' ∈ T), (λ (p : Π (a : α), β a), p a') ⁻¹' P a') = set.univ,
    { ext, simp; intros A6_1,
      apply absurd A4,
      simp,apply A6_1 },
    rw A6,
    simp, },
end


--Unused.
lemma measurable_space.generate_measurable_monotone {α:Type*} {s t:set (set α)}:
  (s ⊆ t) → 
  (∀ u, (measurable_space.generate_measurable s u → 
          measurable_space.generate_measurable t u)) :=
begin
  intros h1 u h2,
  induction h2 with u' h_u' u' h_u' h_ind f h_f h_ind,
  { apply measurable_space.generate_measurable.basic,
    apply h1,
    apply h_u' },
  { apply measurable_space.generate_measurable.empty },
  { apply measurable_space.generate_measurable.compl,
    apply h_ind },
  { apply measurable_space.generate_measurable.union,
    apply h_ind },
end

