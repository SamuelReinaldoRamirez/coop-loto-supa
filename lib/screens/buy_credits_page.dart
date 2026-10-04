import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class BuyCreditsPage extends StatefulWidget {
  const BuyCreditsPage({
    super.key,
  });

  @override
  State<BuyCreditsPage> createState() => _BuyCreditsPageState();
}

class _BuyCreditsPageState extends State<BuyCreditsPage> {
  final ImagePicker _picker = ImagePicker();

  File? _transferProof;

  Future<void> _pickTransferProof() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        _transferProof = File(image.path);
      });
    } catch (e) {
      print('[BuyCredits] Error selecting proof: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de sélectionner la capture.',
          ),
        ),
      );
    }
  }

  void _mockStripePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Paiement Stripe — fonctionnalité bientôt disponible.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          'Acheter des crédits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 20),

            // Icône
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monetization_on_outlined,
                size: 40,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Acheter des crédits',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Choisissez votre mode de paiement pour créditer votre compte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // PAIEMENT STRIPE
            // =========================

            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          size: 28,
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Text(
                            'Paiement par Stripe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Achetez vos crédits directement par carte bancaire.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _mockStripePayment,
                        icon: const Icon(Icons.credit_card),
                        label: const Text(
                          'Acheter des crédits par Stripe',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Frais : 0,25 € + 1,5 % du montant de la transaction.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // PAIEMENT PAR VIREMENT
            // =========================

            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Paiement par virement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'RIB',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const SelectableText(
                      'XXXXXX',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Référence du virement',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const SelectableText(
                      'coop-lotoXXXXXX',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Icon(
                          Icons.monetization_on_outlined,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          '1 crédit = 0,01 €',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // PREUVE DE VIREMENT
                    // =========================

                    const Divider(),

                    const SizedBox(height: 15),

                    const Text(
                      'Preuve du virement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Après avoir effectué le virement, ajoutez une capture d’écran montrant notamment la référence du virement.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    if (_transferProof == null)
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickTransferProof,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                          ),
                          label: const Text(
                            'Ajouter une preuve de virement',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _transferProof!,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(height: 12),

                          OutlinedButton.icon(
                            onPressed: _pickTransferProof,
                            icon: const Icon(
                              Icons.change_circle_outlined,
                            ),
                            label: const Text(
                              'Changer la capture',
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'La preuve sera vérifiée avant l’attribution des crédits.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Exemple : un virement de 10 € correspond à 1 000 crédits.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // Bouton retour
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text(
                  'Retour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}