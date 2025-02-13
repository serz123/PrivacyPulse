import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { H1 } from "@/components/typography/h1";
import { FacebookIcon, InstagramIcon, TwitterIcon } from "lucide-react";

export default function Contact() {
  return (
    <div className="max-h-screen flex flex-col items-center">
      <H1
        text="Contact Us"
        className="text-center text-7xl md:text-8xl lg:text-9xl  font-bold text-primary "
      />
      <p className="text-center text-lg mb-8">
        We’d love to hear from you! Feel free to reach out through the contact
        form below <span className="font-bold">in the future.</span>
      </p>

      <Card className="w-full max-w-3xl">
        <CardHeader>
          <CardTitle className="text-2xl font-semibold text-gray-800">
            Get in Touch
          </CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-6">
            <div>
              <label
                htmlFor="name"
                className="block text-sm font-medium text-gray-700"
              >
                Your Name
              </label>
              <Input
                type="text"
                id="name"
                placeholder="John Doe"
                className="mt-2"
                disabled
              />
            </div>

            <div>
              <label
                htmlFor="email"
                className="block text-sm font-medium text-gray-700"
              >
                Your Email
              </label>
              <Input
                type="email"
                id="email"
                placeholder="you@example.com"
                className="mt-2"
                disabled
              />
            </div>

            <div>
              <label
                htmlFor="message"
                className="block text-sm font-medium text-gray-700"
              >
                Your Message
              </label>
              <Textarea
                id="message"
                rows={4}
                placeholder="Type your message here..."
                className="mt-2"
                disabled
              />
            </div>

            <Button type="submit" className="w-full" disabled>
              Send Message
            </Button>
          </form>
        </CardContent>
      </Card>

      <div className="mt-8 text-center">
        <div className="flex justify-center space-x-8">
          <a href="#" className="text-secondary-foreground hover:text-primary">
            <TwitterIcon />
          </a>
          <a href="#" className="text-secondary-foreground hover:text-primary">
            <FacebookIcon />
          </a>
          <a href="#" className="text-secondary-foreground hover:text-primary">
            <InstagramIcon />
          </a>
        </div>
      </div>
    </div>
  );
}
