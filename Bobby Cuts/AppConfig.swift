import Foundation
import Supabase

enum AppConfig {
    // 1. Go to your Supabase Dashboard -> Project Settings -> API
    // 2. Copy "Project URL" and paste it below
    static let supabaseUrl = URL(string: "YOUR_SUPABASE_URL")!
    
    // 3. Copy "anon" public key and paste it below
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
}

// Initialize the client globally so we can use it everywhere
let supabase = SupabaseClient(
    supabaseURL: AppConfig.supabaseUrl,
    supabaseKey: AppConfig.supabaseAnonKey
)
