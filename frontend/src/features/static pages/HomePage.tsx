import { H1 } from "@/components/typography/h1";
import { P } from "@/components/typography/p";
import { Heart, Shield } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useLogin } from "./hooks/useLogin";

export default function HomePage() {
  const { handleLogin } = useLogin();

  return (
    <div className="flex flex-col md:flex-row items-center w-full justify-between p-4 md:p-8">
      <div className="w-full md:w-2/3 text-center md:text-left">
        <H1 text="Privacy Pulse" className="!text-6xl md:!text-9xl font-bold" />
        <P
          className="text-sm md:text-lg w-full md:w-5/6 mx-auto md:mx-0"
          text="
A data scraping tool for privacy policies that uses your Google account to authenticate you. This tool will help you to keep track of the data that is available to the public, giving you a clear and concise overview of how your personal information is being handled across various platforms. No testing required, just sign in and get started!
        "
        />
        <div className="flex flex-col md:flex-row gap-4 mt-4 justify-center md:justify-start">
          <Button
            className="border border-foreground text-foreground bg-background hover:bg-background hover:border-primary"
            onClick={() => (window.location.href = "/terms-conditions")}
          >
            Read more
          </Button>
          <Button
            className="border border-foreground text-background bg-foreground hover:bg-primary hover:border-primary"
            onClick={handleLogin}
          >
            Log in with Google
          </Button>
        </div>
      </div>
      <div className="hidden md:relative md:flex w-1/3 lg:-mx-20 md:-mx-10 ">
        <Shield className="w-full h-full px-0 py-0" strokeWidth={0.7} />
        <Heart className="w-[85%] h-full absolute top-1/2 left-3/3 transform -translate-x-1/3 -translate-y-1/3 -rotate-45 text-primary fill-primary" />
      </div>
    </div>
  );
}
