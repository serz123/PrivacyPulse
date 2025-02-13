import fetch from 'node-fetch';
import { getOccurrences, getLinkedinProfile, getScrapingData } from './scraper.js';

// Mock `node-fetch`
jest.mock('node-fetch', () => jest.fn());

describe('Scraper Functions', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getOccurrences', () => {
    it('should return the number of occurrences from the API', async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: async () => ({
          searchInformation: { totalResults: "100" },
        }),
      });

      const result = await getOccurrences('test query');
      expect(result).toBe(100);
      expect(fetch).toHaveBeenCalled();
    });

    it('should return 0 if API response is not ok', async () => {
      fetch.mockResolvedValue({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
      });

      const result = await getOccurrences('test query');
      expect(result).toBe(0);
      expect(fetch).toHaveBeenCalled();
    });
  });

  describe('getLinkedinProfile', () => {
    it('should return LinkedIn profile data if found', async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: async () => ({
          items: [
            {
              link: 'https://linkedin.com/in/test-profile',
              title: 'Test User - Software Engineer',
              snippet: 'Experienced in software engineering.',
              pagemap: { metatags: [{ 'og:description': 'A skilled software engineer.' }] },
            },
          ],
        }),
      });

      const result = await getLinkedinProfile('Test User', 'New York', 'Test University');
      expect(result).toEqual({
        title: 'Test User - Software Engineer',
        link: 'https://linkedin.com/in/test-profile',
        snippet: 'Experienced in software engineering.',
        description: 'A skilled software engineer.',
      });
    });

    it('should return null if no profiles match', async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: async () => ({ items: [] }),
      });

      const result = await getLinkedinProfile('Test User', 'New York', 'Test University');
      expect(result).toBe(null);
    });

    it('should return an error message if the API fails', async () => {
      fetch.mockRejectedValue(new Error('Network Error'));

      const result = await getLinkedinProfile('Test User', 'New York', 'Test University');
      expect(result).toBe('Error fetching LinkedIn profiles.');
    });
  });

  describe('getScrapingData', () => {
    it('should return combined scraping data', async () => {
      fetch
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ searchInformation: { totalResults: "5000" } }),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ searchInformation: { totalResults: "100" } }),
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({
            items: [
              {
                link: 'https://linkedin.com/in/test-profile',
                title: 'Test User - Software Engineer',
                snippet: 'Experienced in software engineering.',
                pagemap: { metatags: [{ 'og:description': 'A skilled software engineer.' }] },
              },
            ],
          }),
        });

      const result = await getScrapingData(
        'Test User',
        'testuser@example.com',
        'New York',
        'Test University'
      );

      expect(result).toEqual({
        nameOccurrences: 5000,
        emailOccurrences: 100,
        linkedinProfile: {
          title: 'Test User - Software Engineer',
          link: 'https://linkedin.com/in/test-profile',
          snippet: 'Experienced in software engineering.',
          description: 'A skilled software engineer.',
        },
        email: 'testuser@example.com',
      });
    });

    it('should return default values on API failure', async () => {
      fetch.mockRejectedValue(new Error('Network Error'));

      const result = await getScrapingData(
        'Test User',
        'testuser@example.com',
        'New York',
        'Test University'
      );

      expect(result).toEqual({
        nameOccurrences: 0,
        emailOccurrences: 0,
        linkedinProfile: 'Error fetching LinkedIn profiles.',
        email: 'testuser@example.com',
      });
    });
  });
});
