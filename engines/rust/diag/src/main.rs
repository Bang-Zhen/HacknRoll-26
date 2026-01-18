use serde::Serialize;

#[derive(Serialize)]
struct Out {
    diag: String,
}

fn main() {
    let out = Out {
        diag: "rust-diag-ok".to_string(),
    };
    println!("{}", serde_json::to_string(&out).unwrap());
}
