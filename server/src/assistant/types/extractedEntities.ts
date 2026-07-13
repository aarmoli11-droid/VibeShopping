export interface ExtractedEntities {
  product: string | null;
  products: string[];
  category: string | null;
  categories: string[];
  store: string | null;
  stores: string[];
  recipe: string | null;
  budget: number | null;
  servings: number | null;
  dietaryRestrictions: string[];
  brand: string | null;
  priceMin: number | null;
  priceMax: number | null;
  quantity: number | null;
  unit: string | null;
  comparisonTarget: string | null;
  nutritionGoal: string | null;
}

export function emptyEntities(): ExtractedEntities {
  return {
    product: null,
    products: [],
    category: null,
    categories: [],
    store: null,
    stores: [],
    recipe: null,
    budget: null,
    servings: null,
    dietaryRestrictions: [],
    brand: null,
    priceMin: null,
    priceMax: null,
    quantity: null,
    unit: null,
    comparisonTarget: null,
    nutritionGoal: null,
  };
}
