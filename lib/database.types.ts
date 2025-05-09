export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          name: string
          role: string
          last_active: string
        }
        Insert: {
          id: string
          name: string
          role?: string
          last_active?: string
        }
        Update: {
          id?: string
          name?: string
          role?: string
          last_active?: string
        }
      }
      categories: {
        Row: {
          id: string
          name: string
          icon: string
          user_count: number
        }
        Insert: {
          id?: string
          name: string
          icon: string
          user_count?: number
        }
        Update: {
          id?: string
          name?: string
          icon?: string
          user_count?: number
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}