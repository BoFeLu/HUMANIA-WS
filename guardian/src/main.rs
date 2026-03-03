// C:\HUMANIA\SRC\guardian\src\main.rs
use std::process::Command;
use std::thread;
use std::time::Duration;
use std::fs;

fn main() {
    println!("--- [UH-GUARDIAN-RS ACTIVE] ---");
    let script_path = "C:\\HUMANIA\\humania_run.ps1";

    loop {
        // Verificar si el proceso de PowerShell con el script está corriendo
        let output = Command::new("powershell")
            .args(&["-Command", "Get-Process | Where-Object { $_.CommandLine -like '*humania_run.ps1*' }"])
            .output()
            .expect("Fallo al ejecutar chequeo de proceso");

        if output.stdout.is_empty() {
            println!("[ALERT] Nucleo caido. Reiniciando...");
            let _ = Command::new("powershell")
                .args(&["-File", script_path])
                .spawn();
        }

        // Sleep de 30 segundos (Eficiencia de CPU)
        thread::sleep(Duration::from_secs(30));
    }
}
