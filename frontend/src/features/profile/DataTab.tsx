import { H2 } from "@/components/typography/h2";
import { H3 } from "@/components/typography/h3";
import { Lead } from "@/components/typography/lead";
import { P } from "@/components/typography/p";
import { Small } from "@/components/typography/small";
import { Card } from "@/components/ui/card";
import { Info, Search, User } from "lucide-react";
import { useEffect, useState } from "react";
import {jwtDecode} from "jwt-decode";

interface ScrapedData {
  id: string;
  email: string;
  nameOccurrences: number;
  emailOccurrences: number;
  linkedInTitle: string | null;
  linkedInLink: string | null;
  linkedInSnippet: string | null;
  linkedInDescription: string | null;
  dateScraped: string;
}

export default function DataTab() {
  const [profile, setProfile] = useState<{
    name: string;
    picture: string;
    email: string;
  } | null>(null);

  const [scrapedData, setScrapedData] = useState<ScrapedData | null>(null);

  useEffect(() => {
    const token = localStorage.getItem("token");

    if (token) {
      try {
        const decodedToken = jwtDecode<{
          name: string;
          picture: string;
          email: string;
        }>(token);

        setProfile({
          name: decodedToken.name,
          picture: decodedToken.picture,
          email: decodedToken.email,
        });

        fetchScrapedData();
      } catch (error) {
        console.error("Error decoding token:", error);
      }
    }
  }, []);

  const fetchScrapedData = async () => {
    try {
      const response = await fetch(import.meta.env.VITE_GET_SCRAPING_URL, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });

      if (response.status === 200) {
        const data = await response.json();
        setScrapedData(data);
      }
    } catch (error) {
      console.error("Error fetching scraped data:", error);
    }
  };

  if (profile === null) {
    return <div>Loading profile...</div>;
  }

  const isDataScraped = scrapedData?.dateScraped !== "0001-01-01T00:00:00";

  const rawDescription = scrapedData?.linkedInDescription || "";

  // Extract the relevant parts
  const experienceMatch = rawDescription.match(/Erfarenhet: (.+?) ·/);
  const educationMatch = rawDescription.match(/Utbildning: (.+?) ·/);
  const locationMatch = rawDescription.match(/Plats: (.+?) ·/);
  const contactsMatch = rawDescription.match(/(\d+) kontakter/);

  // Extracted values or defaults
  const experience = experienceMatch ? experienceMatch[1] : "N/A";
  const education = educationMatch ? educationMatch[1] : "N/A";
  const location = locationMatch ? locationMatch[1] : "N/A";
  const contacts = contactsMatch ? contactsMatch[1] : "N/A";

  // Safely access LinkedIn title and snippet
  const linkedInSnippetPart =
    scrapedData?.linkedInSnippet?.split(".")[1]?.split("...")[0] || "N/A";
  const linkedInJobTitle =
    scrapedData?.linkedInTitle?.split(" –")[1] || "N/A";
  const linkedInCompanyName =
    scrapedData?.linkedInTitle?.split(" –")[2]?.split(" |")[0] || "N/A";

  return (
    <div>
      <div className="mb-4">
        <H2
          text={`Data scraped for ${profile.email}`}
          className="border-b-0 -mb-2"
        />
        <Lead text="Here is what our scraping service could find using your Google email address and name." />
      </div>

      {isDataScraped ? (
        <div className="flex flex-col gap-8">
          <div className="flex flex-col gap-8 md:flex-col lg:flex-row">
            <Card className="flex flex-col gap-8 px-8 py-4 bg-muted relative lg:pr-60">
              <H3 text="Personal info" />
              <User className="absolute top-5 right-4" />

              <div className="-space-y-1">
                <Small
                  text="NAME ON GOOGLE ACCOUNT"
                  className="text-muted-foreground font-normal tracking-wide"
                />
                <P
                  text={`Appeared in ${
                    scrapedData?.nameOccurrences || 0
                  } pages.`}
                  className="font-bold"
                />
              </div>

              <div className="-space-y-1">
                <Small
                  text="MAIL ADDRESS"
                  className="text-muted-foreground font-normal tracking-wide"
                />
                <P
                  text={`Appeared in ${
                    scrapedData?.emailOccurrences || 0
                  } pages.`}
                  className="font-bold"
                />
              </div>
            </Card>

            <Card className="flex flex-1 flex-col gap-8 px-8 py-4 relative pr-20">
              <H3 text="Social media" />
              <Info className="absolute top-5 right-4" />

              <div className="-space-y-1">
                <Small
                  text="LINKEDIN"
                  className="text-muted-foreground font-normal tracking-wide"
                />
                <div>
                  {scrapedData?.linkedInLink ? (
                    <a
                      href={scrapedData.linkedInLink}
                      target="_blank"
                      rel="noreferrer"
                      className="text-blue-800 underline"
                    >
                      {scrapedData.linkedInLink}
                    </a>
                  ) : (
                    "N/A"
                  )}
                </div>
              </div>

              <div className="-space-y-1">
                <Small
                  text="LINKEDIN DESCRIPTION"
                  className="text-muted-foreground font-normal tracking-wide"
                />
                <P text={linkedInSnippetPart} />
              </div>
            </Card>
          </div>

          <Card className="flex flex-col gap-8 px-8 py-4 relative pr-20">
            <H3 text="Scraping details" />
            <Search className="absolute top-5 right-4" />

            <div className="-space-y-1">
              <Small
                text="JOB TITLE"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <P text={linkedInJobTitle} />
            </div>

            <div className="-space-y-1">
              <Small
                text="COMPANY NAME"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <P text={linkedInCompanyName} />
            </div>

            <div className="-space-y-1">
              <Small
                text="MORE DETAILS"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <div className="flex flex-row gap-4">
                <p>{`Experience: ${experience}`}</p>
                <p>{`Education: ${education}`}</p>
                <p>{`Location: ${location}`}</p>
                <p>{`Contacts: ${contacts}`}</p>
              </div>
            </div>
          </Card>
        </div>
      ) : (
        <div className="mt-4 p-4 border border-gray-300 rounded-md">
          <p>Data was not scraped for this account yet.</p>
        </div>
      )}
    </div>
  );
}
