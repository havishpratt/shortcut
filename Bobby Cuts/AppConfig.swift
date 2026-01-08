import Foundation
import Supabase

enum AppConfig {
    // 1. Go to your Supabase Dashboard -> Project Settings -> API
    // 2. Copy "Project URL" and paste it below
    static let supabaseUrl = URL(string: "https://urluaiuojyibzbawtuhy.supabase.co")!
    
    // 3. Copy "anon" public key and paste it below
    static let supabaseAnonKey = "sb_publishable__MlAlnYfacq164AouEj_1w_5TDX7Hj1"
}

// Initialize the client globally so we can use it everywhere
let supabase = SupabaseClient(
    supabaseURL: AppConfig.supabaseUrl,
    supabaseKey: AppConfig.supabaseAnonKey
)
