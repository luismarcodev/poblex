import { Injectable } from '@nestjs/common';

const GRAPH_API_VERSION = 'v21.0';
const GRAPH_API_BASE = `https://graph.facebook.com/${GRAPH_API_VERSION}`;

interface GraphApiError {
  error?: { message: string; type: string; code: number };
}

// Cliente HTTP fino sobre Meta Graph API con `fetch` nativo — mismo estilo
// que AemetWeatherWarningAdapter, sin dependencia nueva (nada de axios).
@Injectable()
export class MetaGraphHttpClient {
  async get<T>(path: string, params: Record<string, string> = {}): Promise<T> {
    const url = new URL(`${GRAPH_API_BASE}${path}`);
    for (const [key, value] of Object.entries(params)) {
      url.searchParams.set(key, value);
    }
    return this.parse<T>(await fetch(url));
  }

  async post<T>(path: string, params: Record<string, string> = {}): Promise<T> {
    const url = new URL(`${GRAPH_API_BASE}${path}`);
    return this.parse<T>(
      await fetch(url, {
        method: 'POST',
        body: new URLSearchParams(params),
      }),
    );
  }

  private async parse<T>(response: Response): Promise<T> {
    const data = (await response.json()) as T & GraphApiError;
    if (!response.ok || data.error) {
      const message = data.error
        ? `Meta Graph API error: ${data.error.message} (code ${data.error.code})`
        : `Meta Graph API request failed: HTTP ${response.status}`;
      throw new Error(message);
    }
    return data;
  }
}
