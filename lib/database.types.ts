// Database-types voor Supabase.
//
// Handgeschreven in de canonieke vorm die supabase-js verwacht (met
// Relationships en CompositeTypes), zodat query-resultaten correct getypeerd
// zijn. Sluit aan op de migraties in supabase/migrations.
// Later te regenereren met: supabase gen types typescript --local

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type ProductLine = "BX" | "UX" | "CX";
export type PartType = "attack" | "defense" | "stamina" | "balance";
export type SpinDirection = "right" | "left";
export type Brand = "takara_tomy" | "hasbro";
export type ProductKind =
  | "starter"
  | "booster"
  | "random_booster"
  | "customize_set"
  | "deck_set"
  | "other";
export type BuildKind = "custom" | "competitive" | "deck_slot";
export type PartCondition = "new" | "like_new" | "used" | "worn";

export type Database = {
  public: {
    Tables: {
      part_categories: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          sort_order: number;
        };
        Insert: {
          id: string;
          name: string;
          description?: string | null;
          sort_order?: number;
        };
        Update: {
          id?: string;
          name?: string;
          description?: string | null;
          sort_order?: number;
        };
        Relationships: [];
      };
      parts: {
        Row: {
          id: string;
          canonical_name: string;
          category: string;
          line: ProductLine;
          type: PartType | null;
          weight_grams: number | null;
          spin_direction: SpinDirection | null;
          ratchet_height: string | null;
          contact_points: number | null;
          image_url: string | null;
          wiki_url: string | null;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          canonical_name: string;
          category: string;
          line: ProductLine;
          type?: PartType | null;
          weight_grams?: number | null;
          spin_direction?: SpinDirection | null;
          ratchet_height?: string | null;
          contact_points?: number | null;
          image_url?: string | null;
          wiki_url?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["parts"]["Insert"]>;
        Relationships: [];
      };
      part_aliases: {
        Row: {
          id: string;
          part_id: string;
          brand: Brand;
          name: string;
          region: string | null;
        };
        Insert: {
          id?: string;
          part_id: string;
          brand: Brand;
          name: string;
          region?: string | null;
        };
        Update: Partial<Database["public"]["Tables"]["part_aliases"]["Insert"]>;
        Relationships: [];
      };
      part_variants: {
        Row: {
          id: string;
          part_id: string;
          colorway: string;
          is_default: boolean;
          image_url: string | null;
          wiki_url: string | null;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          part_id: string;
          colorway: string;
          is_default?: boolean;
          image_url?: string | null;
          wiki_url?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["part_variants"]["Insert"]>;
        Relationships: [];
      };
      products: {
        Row: {
          id: string;
          canonical_name: string;
          hasbro_name: string | null;
          product_code: string | null;
          brand: Brand;
          kind: ProductKind;
          line: ProductLine | null;
          release_date: string | null;
          eu_available: boolean;
          eu_release_date: string | null;
          image_url: string | null;
          wiki_url: string | null;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          canonical_name: string;
          hasbro_name?: string | null;
          product_code?: string | null;
          brand: Brand;
          kind?: ProductKind;
          line?: ProductLine | null;
          release_date?: string | null;
          eu_available?: boolean;
          eu_release_date?: string | null;
          image_url?: string | null;
          wiki_url?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["products"]["Insert"]>;
        Relationships: [];
      };
      product_parts: {
        Row: {
          id: string;
          product_id: string;
          part_id: string;
          variant_id: string | null;
          quantity: number;
        };
        Insert: {
          id?: string;
          product_id: string;
          part_id: string;
          variant_id?: string | null;
          quantity?: number;
        };
        Update: Partial<Database["public"]["Tables"]["product_parts"]["Insert"]>;
        Relationships: [];
      };
      build_templates: {
        Row: {
          id: string;
          name: string;
          line: ProductLine;
          subtype: string;
          allows_integrated_bit: boolean;
          description: string | null;
          sort_order: number;
        };
        Insert: {
          id: string;
          name: string;
          line: ProductLine;
          subtype: string;
          allows_integrated_bit?: boolean;
          description?: string | null;
          sort_order?: number;
        };
        Update: Partial<Database["public"]["Tables"]["build_templates"]["Insert"]>;
        Relationships: [];
      };
      build_template_slots: {
        Row: {
          id: string;
          template_id: string;
          category: string;
          min_quantity: number;
          max_quantity: number;
          sort_order: number;
        };
        Insert: {
          id?: string;
          template_id: string;
          category: string;
          min_quantity?: number;
          max_quantity?: number;
          sort_order?: number;
        };
        Update: Partial<
          Database["public"]["Tables"]["build_template_slots"]["Insert"]
        >;
        Relationships: [];
      };
      owned_parts: {
        Row: {
          id: string;
          user_id: string;
          part_id: string;
          variant_id: string | null;
          quantity: number;
          condition: PartCondition;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          part_id: string;
          variant_id?: string | null;
          quantity?: number;
          condition?: PartCondition;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["owned_parts"]["Insert"]>;
        Relationships: [];
      };
      builds: {
        Row: {
          id: string;
          user_id: string | null;
          name: string;
          template_id: string;
          kind: BuildKind;
          source: string | null;
          notes: string | null;
          meta_date: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id?: string | null;
          name: string;
          template_id: string;
          kind?: BuildKind;
          source?: string | null;
          notes?: string | null;
          meta_date?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["builds"]["Insert"]>;
        Relationships: [];
      };
      build_parts: {
        Row: {
          id: string;
          build_id: string;
          part_id: string;
          slot_category: string | null;
          quantity: number;
          notes: string | null;
        };
        Insert: {
          id?: string;
          build_id: string;
          part_id: string;
          slot_category?: string | null;
          quantity?: number;
          notes?: string | null;
        };
        Update: Partial<Database["public"]["Tables"]["build_parts"]["Insert"]>;
        Relationships: [];
      };
      decks: {
        Row: {
          id: string;
          user_id: string;
          name: string;
          build_1_id: string | null;
          build_2_id: string | null;
          build_3_id: string | null;
          ruleset: string;
          lock_chip_exception: boolean;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          name: string;
          build_1_id?: string | null;
          build_2_id?: string | null;
          build_3_id?: string | null;
          ruleset?: string;
          lock_chip_exception?: boolean;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["decks"]["Insert"]>;
        Relationships: [];
      };
    };
    Views: { [_ in never]: never };
    Functions: {
      add_owned_part: {
        Args: {
          p_part_id: string;
          p_variant_id?: string | null;
          p_condition?: PartCondition;
          p_qty?: number;
        };
        Returns: undefined;
      };
      add_product_to_collection: {
        Args: { p_product_id: string; p_condition?: PartCondition };
        Returns: undefined;
      };
    };
    Enums: {
      product_line: ProductLine;
      part_type: PartType;
      spin_direction: SpinDirection;
      brand: Brand;
      product_kind: ProductKind;
      build_kind: BuildKind;
      part_condition: PartCondition;
    };
    CompositeTypes: { [_ in never]: never };
  };
};
