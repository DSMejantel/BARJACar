document.addEventListener("DOMContentLoaded", function () {
    // 1. Cible tous les champs de type 'password' sur la page
    const passwordInputs = document.querySelectorAll('input[type="password"]');

    for (const input of passwordInputs) {
        // Évite de dupliquer si le script est exécuté plusieurs fois
        if (input.parentNode.classList.contains("password-container")) continue;

        // 2. Crée un conteneur parent pour positionner l'icône en CSS relatif
        const container = document.createElement("div");
        container.className = "password-container";
        container.style.position = "relative";
        container.style.display = "flex";
        container.style.alignItems = "center";
        container.style.width = "100%";
        
        // Insère le conteneur à la place du champ dans le DOM, puis déplace le champ dedans
        input.parentNode.insertBefore(container, input);
        container.appendChild(input);

        // 3. Crée le bouton
        const toggleButton = document.createElement("button");
        toggleButton.type = "button";
        toggleButton.className = "password-toggle-btn";
        
        // Utilisation de l'icône SVG locale par défaut
        toggleButton.innerHTML = '<img src="/icons/eye.svg" alt="Afficher le mot de passe" style="width: 20px; height: 20px; display: block;" />';
        
        // Styles pour positionner le bouton proprement
        toggleButton.style.position = "absolute";
        toggleButton.style.right = "10px";
        toggleButton.style.background = "transparent";
        toggleButton.style.border = "none";
        toggleButton.style.cursor = "pointer";
        toggleButton.style.padding = "0";
        toggleButton.style.lineHeight = "1";

        // Ajoute le bouton dans le conteneur
        container.appendChild(toggleButton);

        // 4. Gère le clic pour basculer le type et mettre à jour le fichier SVG
        toggleButton.addEventListener("click", function () {
            const img = toggleButton.querySelector("img");
            if (input.type === "password") {
                input.type = "text";
                img.src = "/icons/eye-off.svg";
                img.alt = "Masquer le mot de passe";
            } else {
                input.type = "password";
                img.src = "/icons/eye.svg";
                img.alt = "Afficher le mot de passe";
            }
        });
    }
});
