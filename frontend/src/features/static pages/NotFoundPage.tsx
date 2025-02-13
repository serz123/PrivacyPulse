import { H1 } from "@/components/typography/h1";

export default function NotFoundPage() {
  return (
    <div className="flex flex-col items-center justify-center ">
        <H1 text="404 - Page Not Found" className="!text-9xl font-bold text-primary mb-10" />
        <p>Sorry, the page you are looking for does not exist. Go back to the <a href="/" className="font-bold">homepage</a>.</p>
    </div>
  );
}
