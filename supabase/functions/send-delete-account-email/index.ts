import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY =
  Deno.env.get("RESEND_API_KEY") || "re_3wuK8saf_3twvK1PNUZas61qhg3uKGFkd";
const FROM_EMAIL = "pogup@mail.gytx.dev";
const TO_EMAIL = "mahelnguindja@gmail.com";

interface DeleteAccountRequest {
  email: string;
  prenom?: string;
  nom?: string;
  raison: string;
  userId?: string;
}

serve(async (req) => {
  // Gérer les requêtes CORS
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
    });
  }

  try {
    // Vérifier que la méthode est POST
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    // Parser le body de la requête
    const body: DeleteAccountRequest = await req.json();

    // Valider les données requises
    if (!body.email || !body.raison) {
      return new Response(
        JSON.stringify({ error: "Email et raison sont requis" }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // Construire le nom complet
    const nomComplet =
      body.prenom && body.nom
        ? `${body.prenom} ${body.nom}`
        : body.prenom || body.nom || "Utilisateur";

    // Construire le contenu de l'email
    const emailSubject = `Demande de suppression de compte - ${body.email}`;
    const emailContent = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <style>
            body {
              font-family: Arial, sans-serif;
              line-height: 1.6;
              color: #333;
            }
            .container {
              max-width: 600px;
              margin: 0 auto;
              padding: 20px;
            }
            .header {
              background: #E30613;
              color: white;
              padding: 20px;
              border-radius: 8px 8px 0 0;
            }
            .content {
              background: #f9f9f9;
              padding: 20px;
              border: 1px solid #ddd;
            }
            .info-box {
              background: white;
              padding: 15px;
              margin: 15px 0;
              border-left: 4px solid #E30613;
            }
            .label {
              font-weight: bold;
              color: #666;
            }
            .value {
              margin-bottom: 10px;
            }
            .footer {
              background: #f5f5f5;
              padding: 15px;
              text-align: center;
              font-size: 12px;
              color: #666;
              border-radius: 0 0 8px 8px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h2>Demande de suppression de compte</h2>
            </div>
            <div class="content">
              <p>Une nouvelle demande de suppression de compte a été reçue.</p>
              
              <div class="info-box">
                <div class="value">
                  <span class="label">Email :</span> ${body.email}
                </div>
                ${
                  body.prenom
                    ? `<div class="value"><span class="label">Prénom :</span> ${body.prenom}</div>`
                    : ""
                }
                ${
                  body.nom
                    ? `<div class="value"><span class="label">Nom :</span> ${body.nom}</div>`
                    : ""
                }
                ${
                  body.userId
                    ? `<div class="value"><span class="label">ID Utilisateur :</span> ${body.userId}</div>`
                    : ""
                }
                <div class="value">
                  <span class="label">Raison de la suppression :</span>
                  <p style="margin-top: 10px; white-space: pre-wrap;">${
                    body.raison
                  }</p>
                </div>
              </div>

              <p style="margin-top: 20px;">
                <strong>Date de la demande :</strong> ${new Date().toLocaleString(
                  "fr-FR",
                  {
                    dateStyle: "full",
                    timeStyle: "long",
                  }
                )}
              </p>
            </div>
            <div class="footer">
              <p>Pog'Up Conciergerie - Système de gestion des demandes</p>
            </div>
          </div>
        </body>
      </html>
    `;

    // Envoyer l'email via Resend API
    const resendResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: TO_EMAIL,
        subject: emailSubject,
        html: emailContent,
        reply_to: body.email,
      }),
    });

    if (!resendResponse.ok) {
      const errorData = await resendResponse.text();
      console.error("Erreur Resend API:", errorData);
      return new Response(
        JSON.stringify({
          error: "Erreur lors de l'envoi de l'email",
          details: errorData,
        }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    const resendData = await resendResponse.json();

    // Retourner une réponse de succès
    return new Response(
      JSON.stringify({
        success: true,
        message: "Email envoyé avec succès",
        resendId: resendData.id,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Erreur:", error);
    return new Response(
      JSON.stringify({
        error: "Erreur interne du serveur",
        details: error.message,
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});
