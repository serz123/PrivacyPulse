import { H1 } from "@/components/typography/h1";
import { H2 } from "@/components/typography/h2";
import { P } from "@/components/typography/p";
import { Small } from "@/components/typography/small";

export default function TermsConditionsPage() {
  return (
    <div>
      <H1 text="Terms and conditions"  />
      <Small
        text="Last Updated: 13/12/2024"
        className="text-muted-foreground ml-2"
      />

      <H2 text="1. Acceptance of Terms" className="mt-8 -mb-4 " />
      <P text="By accessing or using the App, you agree to comply with these Terms. If you do not agree with any part of these Terms, you must not use the App." />

      <H2 text="2. Description of the App" className="mt-8 -mb-4 " />
      <P text="The App is a data scraping tool for privacy policies that uses your Google account to authenticate you. This tool will help you to keep track of the data that is available to the public, giving you a clear and concise overview of how your personal information is being handled across various platforms." />

      <H2 text="3. User Eligibility" className="mt-8 -mb-4 " />
      <P text="To use the App, you must be at least 18 years old or have the permission of a parent or legal guardian. By using the App, you represent that you meet this requirement." />

      <H2 text="4. User Account and Authentication" className="mt-8 -mb-4 " />
      <P text="To access the App’s features, you must log in using your Google account. By doing so, you grant Privacy Pulse access to your Google email and name, which are used solely for the purpose of identifying you and performing the data scraping operations." />

      <H2 text="5. Data Collection and Use" className="mt-8 -mb-4 " />
      <ul className="my-6 ml-6 list-disc [&>li]:mt-2">
        <li>
          <P text="Data Collected: The App collects and processes your Google email and name to search for publicly available data, including but not limited to social media profiles, phone numbers, and addresses associated with you." />
        </li>
        <li>
          <P text="Purpose: The data is used to provide you with a summary of publicly available information about yourself. We do not store, sell, or share your personal data with third parties" />
        </li>

        <li>
          <P text="User Responsibility: By using the App, you consent to this data collection. It is your responsibility to ensure you understand and agree to how the App collects and uses your information." />
        </li>
      </ul>

      <H2 text="6. User Obligations" className="mt-8 -mb-4 " />
      <ul className="my-6 ml-6 list-disc [&>li]:mt-2">
        <li>
          <P text="You agree to use the App only for personal, lawful purposes." />
        </li>

        <li>
          <P text="You agree not attempt to reverse engineer, modify, or create derivative works of the App." />
        </li>

        <li>
          <P text="Refrain from using the App to collect data about other users or individuals without their explicit consent." />
        </li>

        <li>
          <P
            text="You agree not to use the App to scrape, extract, or harvest data for any commercial or unauthorized purpose."
          />
        </li>
      </ul>

      <H2 text="7. Intellectual Property" className="mt-8 -mb-4 " />
      <P text="The App and its original content, features, and functionality are and will remain the exclusive property of Privacy Pulse." />

      <H2 text="8. Limitation of Liability" className="mt-8 -mb-4 " />
      <P text="Privacy Pulse is provided 'as is' without any warranties of any kind, whether express or implied. We do not guarantee the accuracy or completeness of the information retrieved. Privacy Pulse is not liable for any direct, indirect, incidental, consequential, or punitive damages resulting from your use of the App." />

      <H2 text="9. Termination" className="mt-8 -mb-4 " />
      <P text="We reserve the right to terminate or suspend your access to the App at any time without notice for any reason." />

      <H2 text="10. Changes to Terms" className="mt-8 -mb-4 " />
      <P text="We may update these Terms from time to time. Any changes will be posted on this page, and your continued use of the App after changes are made constitutes your acceptance of the new Terms." />

    </div>
  );
}
