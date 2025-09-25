# encrypt.r
# Exécutez : QUARTO_ENCRYPT_PW="monPasse" quarto render ...  (ou exporter la var d'env avant)
if (!requireNamespace("encryptedRmd", quietly = TRUE)) install.packages("encryptedRmd")
if (!requireNamespace("sodium", quietly = TRUE)) install.packages("sodium")

library(encryptedRmd)
library(sodium)

# -> mot de passe (ne pas hardcoder dans le script)
pw <- Sys.getenv("QUARTO_ENCRYPT_PW")
if (nzchar(pw) == FALSE) stop("Définis la variable d'environnement QUARTO_ENCRYPT_PW avant d'exécuter.")

# clé 32-octets dérivée (sha256) — compatible avec encrypt_html_file()
key <- sodium::sha256(charToRaw(pw))

# Choix des fichiers : ici on chiffre uniquement les .html dans docs/portfolio/
html_dir <- file.path("docs", "portfolio")
if (!dir.exists(html_dir)) {
  message("Répertoire ", html_dir, " introuvable — rien à chiffrer.")
} else {
  files <- list.files(html_dir, pattern = "\\.html$", full.names = TRUE)
  # Exclure déjà chiffrés (*.enc.html) et index si nécessaire
  files <- files[!grepl("\\.enc\\.html$", files)]
  if (length(files) == 0) {
    message("Aucun fichier .html à chiffrer dans ", html_dir)
  } else {
    for (f in files) {
      out <- paste0(f, ".enc.html") # output by default if you want another name change ici
      message("Chiffre : ", basename(f), " -> ", basename(out))
      # write_key_file = FALSE pour ne pas créer de fichier clé à côté
      encryptedRmd::encrypt_html_file(path = f,
                                      output_path = out,
                                      key = key,
                                      message_key = FALSE,
                                      write_key_file = FALSE)
    }
    message("Terminé.")
  }
}
