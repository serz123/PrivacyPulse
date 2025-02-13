import { H2 } from "@/components/typography/h2";
import { H3 } from "@/components/typography/h3";
import { Lead } from "@/components/typography/lead";
import { P } from "@/components/typography/p";
import { Small } from "@/components/typography/small";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import { jwtDecode } from "jwt-decode";
import { Info } from "lucide-react";
import { useEffect, useState } from "react";
import { useToast } from "@/hooks/use-toast";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface ProfileData {
  name: string;
  picture: string;
  email: string;
}

interface ScrapedData {
  dateScraped: string;
}

export default function OverviewTab() {
  const [profile, setProfile] = useState<ProfileData | null>(null);
  const [city, setCity] = useState("");
  const [college, setCollege] = useState("");
  const [isScraping, setIsScraping] = useState(false);
  const [showWarning, setShowWarning] = useState(false);
  const [scrapedData, setScrapedData] = useState<ScrapedData | null>(null);
  const [statusText, setStatusText] = useState("No data scraped.");
  const [previousDateScraped, setPreviousDateScraped] = useState<string | null>(
    null
  );
  const { toast } = useToast();

  // Fetch profile data from token on mount
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      try {
        const decodedToken = jwtDecode<ProfileData>(token);
        setProfile({
          name: decodedToken.name,
          picture: decodedToken.picture,
          email: decodedToken.email,
        });
        fetchScrapedData(); // Initial fetch of scraping data
      } catch (error) {
        console.error("Error decoding token:", error);
      }
    }
  }, []);

  // Update status text when scrapedData changes
  useEffect(() => {
    if (
      !scrapedData?.dateScraped ||
      scrapedData.dateScraped === "0001-01-01T00:00:00"
    ) {
      setStatusText("No data scraped.");
    } else if (scrapedData.dateScraped !== previousDateScraped) {
      setPreviousDateScraped(scrapedData.dateScraped);
      setStatusText("Data available in your profile.");
    }
  }, [scrapedData, previousDateScraped]);

  // Fetch scraped data
  const fetchScrapedData = async () => {
    try {
      const response = await fetch(import.meta.env.VITE_GET_SCRAPING_URL, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      if (response.ok) {
        const data = await response.json();
        setScrapedData(data);
      }
    } catch (error) {
      console.error("Error fetching scraped data:", error);
    }
  };

  // Polling function to check for updates in scraping data
  const pollForScrapingCompletion = async () => {
    const maxAttempts = 20;
    let attempts = 0;
    const delay = 3000; // 3 seconds

    const checkStatus = async () => {
      const previousValue = scrapedData?.dateScraped || null;
      await fetchScrapedData();
      return (
        scrapedData?.dateScraped && scrapedData.dateScraped !== previousValue
      );
    };

    while (attempts < maxAttempts) {
      const isComplete = await checkStatus();
      if (isComplete) return; // Exit polling if new data is available
      attempts++;
      await new Promise((resolve) => setTimeout(resolve, delay));
    }

    // if something is wrong with the scraping process
    setStatusText(
      "Scraping took longer than expected. Please check back later."
    );
  };

  // Handle scraping initiation
  const handleScrape = async () => {
    if (!isScraping) {
      setShowWarning(true);
      return;
    }

    if (!city || !college) {
      toast({
        title: "Error",
        description: `${
          !city ? "City" : "College"
        } is required to start scraping.`,
        variant: "destructive",
      });
      return;
    }

    try {
      setStatusText("Scraping in progress...");
      const response = await fetch(import.meta.env.VITE_START_SCRAPING_URL, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ City: city, CollegeName: college }),
      });

      if (response.ok) {
        toast({
          title: "Success",
          description: "Scraping process started.",
          variant: "default",
        });
        await pollForScrapingCompletion();
      } else {
        handleScrapeErrors(response.status);
      }
    } catch (error) {
      console.error("Error starting scraping process:", error);
      toast({
        title: "Error",
        description: "Failed to start scraping. Please try again later.",
        variant: "destructive",
      });
    }
  };

  const handleScrapeErrors = (status: number) => {
    const errorMessages: { [key: number]: string } = {
      400: "Invalid request. Please check your inputs.",
      401: "Unauthorized. Please log in again to start scraping.",
    };

    toast({
      title: "Error",
      description:
        errorMessages[status] ||
        "An unexpected error occurred. Please try again later.",
      variant: "destructive",
    });

    setStatusText("Error while scraping. Please try again.");
  };

  // Format date for display
  const formatDate = (date: string) =>
    new Date(date).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      timeZoneName: "short",
    });

  if (!profile) return <div>Loading profile...</div>;

  return (
    <div>
      <div className="mb-4">
        <H2
          text={`Hello, ${profile.name.split(" ")[0]}!`}
          className="border-b-0 -mb-2"
        />
        <Lead text="Explore information about your Google account and scraping settings." />
      </div>

      <div className="flex flex-col gap-8">
        <div className="flex flex-col gap-8 md:flex-col lg:flex-row">
          <Card className="flex flex-col gap-8 px-8 py-4 bg-muted relative lg:pr-60">
            <H3 text="Google info" />
            <img
              src={profile.picture}
              alt="Profile"
              className="w-20 h-20 rounded-lg absolute top-5 right-4"
            />
            <div className="-space-y-1">
              <Small
                text="NAME ON GOOGLE ACCOUNT"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <P text={profile.name} className="font-bold" />
            </div>
            <div className="-space-y-1">
              <Small
                text="MAIL ADDRESS"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <P text={profile.email} className="font-bold" />
            </div>
          </Card>
          <Card className="flex flex-1 flex-col gap-8 px-8 py-4 relative pr-20">
            <H3 text="Scraping info" />
            <Info className="absolute top-5 right-4" />
            <div className="-space-y-1">
              <Small
                text="LAST SCRAPED"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <P
                text={
                  scrapedData?.dateScraped !== "0001-01-01T00:00:00"
                    ? formatDate(scrapedData?.dateScraped || "")
                    : "Never."
                }
                className="font-bold"
              />
            </div>
            <div className="-space-y-1">
              <Small
                text="STATUS"
                className="text-muted-foreground font-normal tracking-wide"
              />
              <P text={statusText} className="font-bold" />
            </div>
          </Card>
        </div>

        <div className="flex flex-col gap-4">
          <H3 text="We need more information from you" />
          <div className="grid w-full max-w-sm items-center gap-1.5">
            <Label htmlFor="city">City</Label>
            <Input
              id="city"
              type="text"
              placeholder="Enter your city of residence"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              required
              className="border-secondary-foreground"
            />
          </div>
          <div className="grid w-full max-w-sm items-center gap-1.5">
            <Label htmlFor="college">College</Label>
            <Input
              id="college"
              type="text"
              placeholder="Enter your college name"
              value={college}
              onChange={(e) => setCollege(e.target.value)}
              required
              className="border-secondary-foreground"
            />
          </div>
        </div>
      </div>

      <div className="flex items-center space-x-2 mt-8">
        <Checkbox
          id="terms"
          onCheckedChange={(checked) => {
            setIsScraping(checked === true);
            if (checked) setShowWarning(false);
          }}
        />
        <label
          htmlFor="terms"
          className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
        >
          I consent to the use of my Gmail address for data scraping as outlined
          in the terms and conditions.
        </label>
      </div>
      <div className="h-6">
        {showWarning && (
          <p className="text-sm text-primary">
            You must agree to the terms and conditions.
          </p>
        )}
      </div>

      <Button onClick={handleScrape} type="submit">
        Start scraping data
      </Button>
    </div>
  );
}
