import { useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";

export function useLogin() {
  const navigate = useNavigate();

  const handleLogin = useCallback(() => {
    const callbackUrl = `${window.location.origin}/login`;
    const googleClientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;

    const targetUrl = `https://accounts.google.com/o/oauth2/v2/auth?redirect_uri=${encodeURIComponent(
      callbackUrl
    )}&response_type=id_token&client_id=${googleClientId}&scope=openid%20email%20profile&nonce=nonce`;

    window.location.href = targetUrl;
  }, []);

  useEffect(() => {
    const handleLoginCallback = async () => {
      if (window.location.pathname === "/login") {
        const fragment = window.location.hash.substring(1); // Remove the # at the start of the hash
        const params = new URLSearchParams(fragment);
        const idToken = params.get("id_token");

        if (!idToken) {
          console.error("No id_token found in URL");
          return;
        }

        try {
          // Verify the ID token with backend
          const response = await fetch(import.meta.env.VITE_AUTH_URL, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ tokenId: idToken }),
          });

          const text = await response.text();

          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }

          const data = JSON.parse(text);

          if (data.token) {
            // Set the token in local storage
            localStorage.setItem("token", data.token);
            navigate("/profile"); 
          } else {
            console.error("Authentication failed:", data);
          }
        } catch (error) {
          console.error("Error handling login callback:", error);
        }
      }
    };

    handleLoginCallback();
  }, [navigate]);

  const handleLogout = useCallback(() => {
    localStorage.removeItem("token");
    navigate("/");
  }, [navigate]);

  return { handleLogin, handleLogout };
}
