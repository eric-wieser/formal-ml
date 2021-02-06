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
import data.rat
import data.fin


lemma eq_or_ne {α:Type*} [D:decidable_eq α] {x y:α}:(x=y)∨ (x≠ y) :=
begin
  have A1:decidable (x=y) := D x y,
  cases A1,
  {
    right,
    apply A1,
  },
  {
    left,
    apply A1,
  }
end


lemma lt_or_not_lt {α:Type*} [D:linear_order α] {x y:α}:(x<y)∨ ¬ (x< y) :=
begin
  have A1:decidable (x<y) := linear_order.decidable_lt x y,
  cases A1,
  {
    right,
    apply A1,
  },
  {
    left,
    apply A1,
  }
end


lemma le_or_not_le {α:Type*} [D:linear_order α] {x y:α}:(x≤y)∨ ¬(x≤y) :=
begin
  have A1:decidable (x≤y) := linear_order.decidable_le x y,
  cases A1,
  {
    right,
    apply A1,
  },
  {
    left,
    apply A1,
  }
end


lemma le_iff_not_gt {α:Type*} [linear_order α] {a b:α}:a ≤ b ↔ ¬ a > b :=
begin
  split,
  {
    intro A1,
    intro A2,
    apply not_le_of_gt A2,
    apply A1,
  },
  {
    apply le_of_not_gt,
  }
end

lemma has_le_fun_def {α β:Type*} [preorder β] {f g:α → β}: f ≤ g = (∀ a:α, f a ≤ g a) := rfl


lemma le_func_def2 {α β:Type*} [preorder β] {f g:α → β}:(f ≤ g) ↔ (∀ n:α, f n ≤ g n) :=
begin
  refl,
end


lemma function.le_trans {α β:Type*} [partial_order β] {f g h:α → β}:f ≤ g → g ≤ h → f ≤ h :=
begin
  intros A1 A2,
  intro x,
  apply le_trans,
  apply A1,
  apply A2,
end


lemma classical.some_func {α β:Type*} {P:α → β → Prop}:
    (∀ a:α, ∃ b:β,  P a b) → (∃ f:α → β, ∀ a:α, P a (f a)) :=
begin
  intros A1,
  let f:α → β := λ a:α, classical.some (A1 a),
  begin
    apply exists.intro f,
    intro a,
    have A2:P a (classical.some (A1 a)),
    {
      apply classical.some_spec,
    },
    have A3:f a = (classical.some (A1 a)),
    {
      simp,
    },
    rw ← A3 at A2,
    apply A2,
  end
end

lemma classical.forall_of_not_exists_not {α:Type*} {P:α → Prop}:(¬(∃ a:α, ¬ P a))→(∀ a:α, P a) :=
begin
  intro A1,
  rw ← @decidable.not_exists_not _ _ (λ x, @classical.prop_decidable _),
  apply A1,
end

lemma classical.exists_not_of_not_forall {α:Type*} {P:α → Prop}:(¬(∀ a:α, P a))→ (∃ a:α, ¬ P a) :=
begin
  intro A1,
  apply classical.by_contradiction,
  intro A2,  
  apply A1,
  apply classical.forall_of_not_exists_not,
  apply A2,
end



lemma classical.not_forall_iff_exists_not {α:Type*} {P:α → Prop}:(¬(∀ a:α, P a)) ↔(∃ a:α, ¬ P a) :=
begin
  split,
  {
    apply classical.exists_not_of_not_forall,
    --apply A1,
  },
  {
    apply not_forall_of_exists_not,
    --apply A1,
  },
end


lemma not_exists_iff_forall_not {α:Sort*} {P:α → Prop}:
    (¬(∃ a:α, P a)) ↔(∀ a:α, ¬ P a) :=
begin
  split,
  {
    apply forall_not_of_not_exists,
  },
  {
    apply not_exists_of_forall_not,
    --apply A1,
  },
end


lemma classical.exists_of_not_forall_not {α:Sort*} {P:α → Prop}:
    (¬∀ a:α, ¬ P a)  → (∃ a:α, P a) :=
begin
  intro A1,
  cases (classical.em (∃ (a:α), P a)) with A2 A2,
  {
    apply A2,
  },
  {
    exfalso,
    rw not_exists_iff_forall_not at A2,
    apply A1,
    apply A2,
  },
end


lemma canonically_ordered_comm_semiring.add_le_add_right {α:Type*}
    [canonically_ordered_comm_semiring α] (a b:α):a≤ b → (∀ c, a + c ≤ b + c) :=
begin
  intros A1 c,
  rw add_comm a c,
  rw add_comm b c,
  apply canonically_ordered_comm_semiring.add_le_add_left,
  apply A1,
end

--This seems to be legitimately new.
lemma  lt_iff_le_not_eq {α:Type*} [linear_order α] {a b:α}:
    (a < b) ↔ ((a ≤ b) ∧  (a ≠ b)) :=
begin
  split;intros A1,
  {
    split,
    {
      apply le_of_lt A1,
    },
    {
      apply ne_of_lt A1,
    },
  },
  {
    rw lt_iff_le_not_le,
    split,
    {
      apply A1.left,
    },
    {
      intro A2,
      apply A1.right,
      apply  le_antisymm,
      apply A1.left,
      apply A2,
    },
  },
end

lemma le_add_of_nonneg {β:Type*} [ordered_add_comm_monoid β] (a b:β):
  0 ≤ b → a ≤ a + b :=
begin
  intros A1,
  have B1:a + 0 ≤ a + b,
  {
    apply @add_le_add,
    apply le_refl a,
    apply A1,
  },
  rw add_zero at B1,
  apply B1,
end


lemma le_add_nonnegative {β:Type*} [canonically_ordered_add_monoid β] (a b:β):
  a ≤ a + b :=
begin
  apply le_add_of_nonneg,
  apply zero_le,
end

