export interface PublishToFacebookParams {
  pageAccessToken: string;
  pageId: string;
  message: string;
  imageUrl?: string;
}

export interface FacebookPublishResult {
  externalPostId: string;
}

export interface CreateInstagramContainerParams {
  igBusinessAccountId: string;
  accessToken: string;
  imageUrl: string;
  caption: string;
}

export type InstagramContainerStatus =
  'in_progress' | 'finished' | 'error' | 'expired';

// No unificado a propósito: Facebook es prácticamente síncrono (un POST),
// Instagram exige crear un contenedor, sondear su estado y solo entonces
// publicarlo — son dos contratos de API genuinamente distintos, forzarlos
// a una interfaz común sería una abstracción falsa.
export interface SocialPublisherPort {
  publishToFacebook(
    params: PublishToFacebookParams,
  ): Promise<FacebookPublishResult>;

  createInstagramContainer(
    params: CreateInstagramContainerParams,
  ): Promise<{ containerId: string }>;

  getInstagramContainerStatus(
    containerId: string,
    accessToken: string,
  ): Promise<InstagramContainerStatus>;

  // La API real de Meta publica contra /{ig-business-account-id}/media_publish
  // con creation_id={containerId} — el id de contenedor por sí solo no basta,
  // hace falta el nodo de cuenta contra el que se publica.
  publishInstagramContainer(
    igBusinessAccountId: string,
    containerId: string,
    accessToken: string,
  ): Promise<{ externalPostId: string }>;
}

export const SOCIAL_PUBLISHER_PORT = Symbol('SOCIAL_PUBLISHER_PORT');
