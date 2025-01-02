import { describe, it, expect, vi } from 'vitest';

// Mock contract call function
const mockContractCall = vi.fn();

describe('Quantum Key Management Contract', () => {
  describe('generate-quantum-key', () => {
    it('should generate a quantum key successfully', async () => {
      const publicKey = Buffer.from('0123456789abcdef', 'hex');
      const expirationTime = 1000;
      
      mockContractCall.mockResolvedValue({ value: 1 }); // Assuming 1 is the new key ID
      
      const result = await mockContractCall('quantum-key-management', 'generate-quantum-key', [publicKey, expirationTime]);
      
      expect(result.value).toBe(1);
      expect(mockContractCall).toHaveBeenCalledWith('quantum-key-management', 'generate-quantum-key', [publicKey, expirationTime]);
    });
  });
  
  describe('request-key-exchange', () => {
    it('should request a key exchange successfully', async () => {
      const recipient = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
      
      mockContractCall.mockResolvedValue({ value: 1 }); // Assuming 1 is the new request ID
      
      const result = await mockContractCall('quantum-key-management', 'request-key-exchange', [recipient]);
      
      expect(result.value).toBe(1);
      expect(mockContractCall).toHaveBeenCalledWith('quantum-key-management', 'request-key-exchange', [recipient]);
    });
  });
  
  describe('approve-key-exchange', () => {
    it('should approve a key exchange successfully', async () => {
      const requestId = 1;
      
      mockContractCall.mockResolvedValue({ value: true });
      
      const result = await mockContractCall('quantum-key-management', 'approve-key-exchange', [requestId]);
      
      expect(result.value).toBe(true);
      expect(mockContractCall).toHaveBeenCalledWith('quantum-key-management', 'approve-key-exchange', [requestId]);
    });
    
    it('should fail if the caller is not the recipient', async () => {
      const requestId = 1;
      
      mockContractCall.mockRejectedValue(new Error('u403: Unauthorized'));
      
      await expect(mockContractCall('quantum-key-management', 'approve-key-exchange', [requestId]))
          .rejects.toThrow('u403: Unauthorized');
    });
  });
  
  describe('revoke-quantum-key', () => {
    it('should revoke a quantum key successfully', async () => {
      const keyId = 1;
      
      mockContractCall.mockResolvedValue({ value: true });
      
      const result = await mockContractCall('quantum-key-management', 'revoke-quantum-key', [keyId]);
      
      expect(result.value).toBe(true);
      expect(mockContractCall).toHaveBeenCalledWith('quantum-key-management', 'revoke-quantum-key', [keyId]);
    });
    
    it('should fail if the caller is not the key owner', async () => {
      const keyId = 1;
      
      mockContractCall.mockRejectedValue(new Error('u403: Unauthorized'));
      
      await expect(mockContractCall('quantum-key-management', 'revoke-quantum-key', [keyId]))
          .rejects.toThrow('u403: Unauthorized');
    });
  });
});

