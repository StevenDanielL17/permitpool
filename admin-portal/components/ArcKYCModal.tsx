'use client';

import { useState, useEffect } from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { CheckCircle2, Loader2, Upload } from 'lucide-react';

interface ArcKYCModalProps {
  isOpen: boolean;
  onClose: () => void;
  onComplete: (credentialHash: string) => void;
  userAddress: string;
}

export function ArcKYCModal({ isOpen, onClose, onComplete, userAddress }: ArcKYCModalProps) {
  const [step, setStep] = useState<'start' | 'processing' | 'complete'>('start');
  const [credential, setCredential] = useState('');

  // Reset when modal opens
  useEffect(() => {
    if (isOpen) {
      setStep('start');
      setCredential('');
    }
  }, [isOpen]);

  const handleStart = () => {
    setStep('processing');

    // Simulate KYC processing
    setTimeout(() => {
      // Use fixed credential to match on-chain whitelist
      // This prevents "Gas Limit Too High" errors caused by reverts
      const mockCredential = "VALID_ARC_TEST_CREDENTIAL";
      setCredential(mockCredential);
      setStep('complete');
    }, 2000);
  };

  const handleComplete = () => {
    onComplete(credential);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md">
        {step === 'start' && (
          <>
            <DialogHeader>
              <DialogTitle>Verify Identity</DialogTitle>
              <DialogDescription>
                Complete KYC verification for {userAddress.slice(0, 6)}...{userAddress.slice(-4)}
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="flex items-center gap-4 p-4 border rounded-lg">
                <Upload className="h-8 w-8 text-blue-600" />
                <div>
                  <h4 className="font-medium">Upload Documents</h4>
                  <p className="text-sm text-gray-600">Government ID & Proof of Address</p>
                </div>
              </div>
              <Button onClick={handleStart} className="w-full">
                Start Verification
              </Button>
            </div>
          </>
        )}

        {step === 'processing' && (
          <>
            <DialogHeader>
              <DialogTitle>Processing...</DialogTitle>
              <DialogDescription>
                Verifying your identity with Arc
              </DialogDescription>
            </DialogHeader>
            <div className="flex flex-col items-center justify-center py-8">
              <Loader2 className="h-12 w-12 animate-spin text-blue-600 mb-4" />
              <p className="text-sm text-gray-600">This may take a few moments</p>
            </div>
          </>
        )}

        {step === 'complete' && (
          <>
            <DialogHeader>
              <DialogTitle>Verification Complete!</DialogTitle>
              <DialogDescription>
                Your Arc credential has been generated
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="flex flex-col items-center">
                <CheckCircle2 className="h-16 w-16 text-green-600 mb-4" />
                <p className="text-sm text-gray-600 mb-2">Credential Hash:</p>
                <code className="text-xs bg-gray-100 p-2 rounded break-all">
                  {credential}
                </code>
              </div>
              <Button onClick={handleComplete} className="w-full">
                Complete License Issuance
              </Button>
            </div>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
}
