export interface PresignedUploadUrl {
  uploadUrl: string;
  publicUrl: string;
  expiresInSeconds: number;
}

export interface PutObjectParams {
  key: string;
  contentType: string;
  body: Buffer;
}

export interface FileStoragePort {
  // Subida indirecta (adjuntos de gestor autenticado): el cliente sube
  // directo al almacenamiento con una URL prefirmada.
  createPresignedUploadUrl(params: {
    key: string;
    contentType: string;
  }): Promise<PresignedUploadUrl>;

  // Subida a través del backend. Necesaria cuando el contenido viene de un
  // usuario NO autenticado (fotos de incidencias): solo pasando los bytes por
  // el servidor se puede validar el tipo real del fichero.
  putObject(params: PutObjectParams): Promise<{ publicUrl: string }>;

  // Purga de ficheros. Recibe la URL pública porque es lo único que se guarda
  // en base de datos; el adaptador sabe cómo derivar la clave.
  deleteByPublicUrl(publicUrl: string): Promise<void>;
}

export const FILE_STORAGE_PORT = Symbol('FILE_STORAGE_PORT');
